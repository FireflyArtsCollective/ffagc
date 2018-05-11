require 'csv'

#
# Allows for Artist identities to be revealed and more fully featured
# order/scope options.
#
# Views here differ significantly from the non-admin versions.
#
class Admins::GrantSubmissionsController < ApplicationController
  load_and_authorize_resource

  before_filter :initialize_grants

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
    @show_scores = params[:scores] == 'true' || cookies[:show_scores] == 'true'
    @show_funded = params[:funded] || cookies[:show_funded] || 'all'
    @order = params[:order] || cookies[:order] || 'name'

    cookies[:scope] = @scope
    cookies[:grantscope] = @grantscope
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

    if @show_funded != 'all'
      @grant_submissions = @grant_submissions.where("granted_funding_dollars > 0")
    end

    @results = VoteResult.results(@grant_submissions)

    if @order == 'score'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, -gs.avg_score] }
    elsif @order == 'name'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, gs.name] }
    end

    respond_to do |format|
      format.html
      format.csv do
        csv_string = CSV.generate do |csv|
          csv << ['Grant', 'Name', 'Funding Amount', 'Artist Nickname',
                  'Contact Name', 'Contact Email', 'Street', 'City',
                  'State/Province', 'Country', 'Postal Code']
          @grant_submissions.each do |gs|
            grant = Grant.where(id: gs.grant_id).take
            artist = Artist.where(id: gs.artist_id).take
            funding = gs.granted_funding_dollars || 0
            csv << [grant.name, gs.name, funding, artist.name,
                    artist.contact_name, artist.email, artist.contact_street,
                    artist.contact_city, artist.contact_state,
                    artist.contact_country, artist.contact_zipcode]
          end
        end

        render text: csv_string
      end
    end
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
        rescue
          flash[:warning] = "Error sending email (#{sent} sent)"
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
