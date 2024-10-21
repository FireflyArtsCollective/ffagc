class VotesController < ApplicationController
  load_and_authorize_resource only: [:index, :update]

  def index
    @scope = 'assigned'

    if params[:scope] == 'all'
      @scope = 'all'
    end

    @grant_submissions = if @scope == 'assigned' && current_voter.present?
      current_voter.grant_submissions.where(grant_id: active_vote_grants).accessible_by(current_ability)
    else
      # Filter active grants by the ones that this voter is participating in.
      current_voter_grants = active_vote_grants.map do |g|
        g if GrantsVoter.where(voter: current_voter, grant: g).exists?
      end
      GrantSubmission.where(grant_id: current_voter_grants).accessible_by(current_ability)
    end

    if current_voter.present?
      @votes = @grant_submissions.map do |gs|
        vote = current_voter.votes.where(grant_submission: gs).first_or_create
        [gs.id, vote]
      end
      @votes = @votes.to_h
    end

    @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, gs.name] }
  end

  def update
    if !current_voter.verified
      head :unauthorized
      return
    end
    @grant_submissions = GrantSubmission.where(grant_id: active_vote_grants)

    # Realistically, only one var will ever change at a time because the user
    # can only change one thing at once.  Really the submit function should
    # just pass the one item that changed.
    @grant_submissions.each do |gs|
      vote = Vote.where("voter_id = ? AND grant_submission_id = ?", current_voter.id, gs.id).take
      # nil means "was not set".  If the user sets to blank, it will be " ".
      if params['t'][gs.id.to_s] == nil
        next
      end

      changed = false
      if vote.score_t.to_s != params['t'][gs.id.to_s]
        vote.score_t = params['t'][gs.id.to_s]
        changed = true
      end
      if vote.score_c.to_s != params['c'][gs.id.to_s]
        vote.score_c = params['c'][gs.id.to_s]
        changed = true
      end
      if vote.score_f.to_s != params['f'][gs.id.to_s]
        vote.score_f = params['f'][gs.id.to_s]
        changed = true
      end
      if changed
        vote.save
      end
    end

    render :json => { }
  end
end
