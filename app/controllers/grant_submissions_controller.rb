require 'grant_contract'

class GrantSubmissionsController < ApplicationController
  load_and_authorize_resource

  before_action :initialize_grants

  def initialize_grants
    @grants = Grant.all
  end

  def initialize_other_submissions
    @other_submissions = GrantSubmission
        .where(artist_id: @grant_submission.artist_id)
        .where.not(id: @grant_submission.id)
  end

  def set_submission_tags(tag_id_list)
    # Just delete existing tags and then recreate them
    SubmissionTag.where(grant_submission_id: @grant_submission.id).destroy_all
    if tag_id_list == nil
      return
    end
    tag_id_list.each do |t|
      begin
        SubmissionTag.create(
          tag: Tag.find(t.to_i),
          grant_submission: GrantSubmission.find(@grant_submission.id),
        )
      rescue
        # Ignore exceptions due to bad params, etc.
      end
    end
  end

  # We tolerate blank entries, entries with dollar signs, entries with commas,
  # and entries with decimal points (which we destroy)
  # This should be kept in sync with new.js.
  def clean_funding_values(levels)
    normed_list = []
    levels.each do |level|
      if level == ""
        next
      end
      level = level.gsub("$", "")
      level = level.gsub(",", "")
      normed_list.append(level.to_i)
    end
    return normed_list.join(",")
  end

  def create
    @grant_submission.artist_id = current_artist.id
    @grant_submission.funding_requests_csv = clean_funding_values(params["funding_levels"])
    if @grant_submission.save
      set_submission_tags(params["submission_tags"])
      redirect_to action: 'index'
    else
      render 'failure'
    end
  end

  def destroy
    @grant_submission&.destroy!

    redirect_to action: 'index'
  end

  def update
    @grant_submission.attributes = grant_update_params
    if params.has_key?(:funding_levels)
      @grant_submission.funding_requests_csv = clean_funding_values(params["funding_levels"])
    end

    if @grant_submission.save
      if params.has_key?(:submission_tags)
        set_submission_tags(params["submission_tags"])
      end
      if admin_logged_in?
        redirect_to admins_grant_submissions_path
      else
        redirect_to action: 'index'
      end
    else
      render 'failure'
    end
  end

  def index
    # Voters and admins can look at individual grants (show), but they shouldn't
    # be able to look at the index.
    if !artist_logged_in?
      deny_access
    end
    @celebrate_funded = artist_logged_in? && @grant_submissions.funded.exists?
  end

  def show
    initialize_other_submissions
  end

  def discuss
    initialize_other_submissions
  end

  def edit
    # Don't allow an artist to decide post-decision that they want a different
    # grant category.
    # TODO move this logic to Ability
    @grant_change_disable = false
    if @grant_submission.funding_decision && !admin_logged_in?
      @grant_change_disable = true
    end

    # Change breadcrumb based on referer
    @meeting_referer = false
    if request.referer && URI(request.referer).path == "/admins/grant_submissions"
      @meeting_referer = true
    end

    @proposal = Proposal.new
    initialize_other_submissions
    @request_levels = @grant_submission.funding_requests_as_list
    render 'edit'
  end

  def generate_contract
    @grant_submission = GrantSubmission.find(params[:id])

    unless @grant_submission.funded?
      flash[:danger] = "Grant Submission must be funded to create contract"
      logger.warn "tried to generate contract for non-funded grant"
      redirect_to "/"
      return
    end

    grant_name = @grant_submission.grant.name
    contract_template = @grant_submission.grant.contract_template
    artist_name = @grant_submission.artist.name

    respond_to do |format|
      format.html
      format.pdf do
        now = DateTime.current
        pdf = GrantContract.new(contract_template, @grant_submission.name, artist_name,
            @grant_submission.granted_funding_dollars, now)
        send_data pdf.render, filename:
          contract_filename(@grant_submission, contract_template, now),
          type: "application/pdf"
      end
    end
  end

  private

  def contract_filename(gs, contract_template, now)
    title = @grant_submission.name.gsub!(/[^0-9A-Za-z.\-]/, '_')
    "#{title}_#{contract_template}_Contract_#{now.strftime("%Y%m%d")}.pdf"
  end

  def grant_submission_params
    params.require(:grant_submission).permit(:name, :proposal, :grant_id, :funding_levels, :submission_tags)
  end

  def grant_update_params
    allowed_params = [:name, :grant_id, :funding_levels, :proposal]

    if admin_logged_in?
      allowed_params.push(:granted_funding_dollars, :funding_decision)
    end

    if can? :edit_questions, GrantSubmission
      allowed_params.push(:questions, :private_funding_notes, :public_funding_notes)
    end

    if can? :edit_answers, GrantSubmission
      allowed_params.push(:answers)
    end

    par = params.require(:grant_submission).permit(allowed_params)

    # TODO this works but doesn't seem like the correct way
    proposal_attributes = params.require(:grant_submission).permit(proposals_attributes: :file)["proposals_attributes"]
    if proposal_attributes.present?
      par["proposals_attributes"] = [proposal_attributes]
    end

    par
  end

  def grant_contract_params
    params.permit(:id, :format, :submission_id, :authenticity_token)
  end
end
