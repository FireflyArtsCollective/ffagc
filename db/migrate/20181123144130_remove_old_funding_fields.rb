class RemoveOldFundingFields < ActiveRecord::Migration[4.2]
  def change
    GrantSubmission.update_all("funding_requests_csv=requested_funding_dollars")
    Grant.update_all("funding_levels_csv=max_funding_dollars")
    remove_column :grant_submissions, :requested_funding_dollars
    remove_column :grants, :max_funding_dollars
  end
end
