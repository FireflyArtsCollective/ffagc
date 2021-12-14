class AddVoterToVoterSubmissionAssignment < ActiveRecord::Migration[4.2]
  def change
    add_reference :voter_submission_assignments, :voter
  end
end
