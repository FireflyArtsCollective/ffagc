class AddRequestedFundingToGrantSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :grant_submissions, :requested_funding_dollars, :integer
  end
end
