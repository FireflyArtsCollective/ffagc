class AddSignedAgreementToVoterSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :voter_surveys, :signed_agreement, :boolean, default: false
  end
end
