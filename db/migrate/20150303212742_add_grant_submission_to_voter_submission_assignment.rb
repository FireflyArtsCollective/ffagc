class AddGrantSubmissionToVoterSubmissionAssignment < ActiveRecord::Migration[4.2]
  def change
    add_reference :voter_submission_assignments, :grant_submission
  end
end
