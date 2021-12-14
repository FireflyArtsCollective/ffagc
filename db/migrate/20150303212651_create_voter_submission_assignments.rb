class CreateVoterSubmissionAssignments < ActiveRecord::Migration[4.2]
  def change
    create_table :voter_submission_assignments do |t|

      t.timestamps
    end
  end
end
