class AddFundingNotesToGrantSubmission < ActiveRecord::Migration
  def change
    add_column :grant_submissions, :private_funding_notes, :string
    add_column :grant_submissions, :public_funding_notes, :string
  end
end
