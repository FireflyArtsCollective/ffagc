class AddVoterToVoterSurvey < ActiveRecord::Migration[4.2]
  def change
    add_reference :voter_surveys, :voter, index: true
  end
end
