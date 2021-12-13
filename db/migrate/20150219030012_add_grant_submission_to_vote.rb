class AddGrantSubmissionToVote < ActiveRecord::Migration[4.2]
  def change
    add_reference :votes, :grant_submission
  end
end
