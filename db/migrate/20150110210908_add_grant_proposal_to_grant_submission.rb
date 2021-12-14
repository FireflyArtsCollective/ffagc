class AddGrantProposalToGrantSubmission < ActiveRecord::Migration[4.2]
  def change
    add_column :grant_submissions, :proposal, :string
  end
end
