class AddFundingToGrantSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :grant_submissions, :granted_funding_dollars, :integer
    add_column :grant_submissions, :funded, :boolean
  end
end
