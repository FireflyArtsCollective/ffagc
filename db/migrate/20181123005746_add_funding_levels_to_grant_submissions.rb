class AddFundingLevelsToGrantSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_column :grant_submissions, :funding_requests_csv, :string
  end
end
