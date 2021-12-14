class RenameFundedToFundingDecision < ActiveRecord::Migration[4.2]
  def change
    rename_column :grant_submissions, :funded, :funding_decision
  end
end
