require 'csv'

#
# Allows for Artist identities to be revealed and more fully featured
# order/scope options.
#
# Views here differ significantly from the non-admin versions.
#
class Admins::GrantSubmissionsController < ApplicationController
  load_and_authorize_resource

  before_action :initialize_grants

  def initialize_grants
    @grants = Grant.all
  end

  def index
    # TODO: should be handled by Ability somehow.
    if !admin_logged_in?
      deny_access
      return
    end
    @scope = params[:scope] || cookies[:scope] || 'active'
    @grantscope = params[:grantscope] || cookies[:grantscope] || 'all'
    @tagscope = params[:tagscope] || cookies[:tagscope] || 'any'
    if !params[:show_scores].to_s.empty?
      @show_scores = params[:show_scores] == 'true' || false
    else
      @show_scores = cookies[:show_scores] == 'true' || false
    end
    @show_funded = params[:funded] || cookies[:show_funded] || 'all'
    @order = params[:order] || cookies[:order] || 'name'

    cookies[:scope] = @scope
    cookies[:grantscope] = @grantscope
    cookies[:tagscope] = @tagscope
    cookies[:show_scores] = @show_scores
    cookies[:show_funded] = @show_funded
    cookies[:order] = @order

    if can? :reveal_identities, GrantSubmission
      @revealed = params[:reveal] == 'true'
    end

    if @scope == 'active'
      @grant_submissions = @grant_submissions.where(grant_id: active_vote_grants)
    end

    if @grantscope != 'all'
      @grant_submissions = @grant_submissions.joins(:grant).where("grants.name = ?", @grantscope)
    end

    if @tagscope != 'any'
      @grant_submissions = @grant_submissions.joins(:submission_tag).where("submission_tags.tag_id = ?", @tagscope)
    end

    if @show_funded != 'all'
      @grant_submissions = @grant_submissions.where("granted_funding_dollars > 0")
    end

    @results = VoteResult.results(@grant_submissions)

    if @order == 'score'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, -gs.avg_score] }
    elsif @order == 'name'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, gs.name] }
    elsif @order == 'requested'
      @grant_submissions = @grant_submissions.to_a.sort { |gs1, gs2| gs1.by_requested(gs2) }
    end

    respond_to do |format|
      format.html
      format.csv do
        csv_string = CSV.generate do |csv|
          csv << ['Grant', 'Name', 'Tags', 'Artist Nickname', 'Funding Amount',
                  'Submission URL', 'Contact Name', 'Contact Email',
                  'Payment Method', 'Paypal Email', 'Street', 'City',
                  'State/Province', 'Country', 'Postal Code']
          @grant_submissions.each do |gs|
            grant = Grant.where(id: gs.grant_id).take
            tags = gs.tags(true).join(",")
            funding = gs.granted_funding_dollars || 0
            artist = Artist.where(id: gs.artist_id).take
            url = "https://grants.fireflyartscollective.org/grant_submissions/#{gs.id}"
            csv << [grant.name, gs.name, tags, artist.name, funding, url,
                    artist.contact_name, artist.email, "", "",
                    artist.contact_street, artist.contact_city,
                    artist.contact_state, artist.contact_country,
                    artist.contact_zipcode]
          end
        end

        render text: csv_string
      end
    end
  end

  def discuss
    @grant_submission = GrantSubmission.where(id: params[:grant_submission_id]).take
    if @grant_submission == nil
      flash[:warning] = "No such grant submission to discuss"
      redirect_to action: 'index'
      return
    end
    @other_submissions = GrantSubmission
        .where(artist_id: @grant_submission.artist_id)
        .where.not(id: @grant_submission.id)
  end

  def send_fund_emails
    ids = params[:ids]&.split(',') || []
    @grant_submissions = GrantSubmission.where(id: ids)

    sent = 0
    @grant_submissions.each do |gs|
      if params[:send_email] == "true"
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        begin
          if gs.granted_funding_dollars != nil && gs.granted_funding_dollars > 0
            UserMailer.grant_funded(gs, artist, grant, event_year).deliver
            logger.info "email: grant funded sent to #{artist.email}"
          else
            UserMailer.grant_not_funded(gs, artist, grant, event_year).deliver
            logger.info "email: grant not funded sent to #{artist.email}"
          end
        rescue StandardError => e
          logger.error e.message + ", aborting"
          flash[:warning] = "Error sending email (#{sent} sent): " + e.message
          redirect_to action: 'index'
          return
        end
        sent += 1
      end
      gs.funding_decision = true
      gs.save
    end

    flash[:info] = "#{sent} Funding Emails Sent"
    redirect_to action: 'index'
  end

  def send_question_emails
    ids = params[:ids]&.split(',') || []
    @grant_submissions = GrantSubmission.where(id: ids)

    sent = 0
    @grant_submissions.each do |gs|
      if gs.questions != nil && gs.has_questions?
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        begin
          UserMailer.notify_questions(gs, artist, grant, event_year).deliver
          logger.info "email: questions notification sent to #{artist.email}"
        rescue
          flash[:warning] = "Error sending emails (#{sent} sent)"
          redirect_to action: 'index'
          return
        end
        sent += 1
      end
    end

    flash[:info] = "#{sent} Question Notification Emails Sent"
    redirect_to action: 'index'
  end
end
