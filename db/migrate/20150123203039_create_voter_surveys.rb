class CreateVoterSurveys < ActiveRecord::Migration[4.2]
  def change
    create_table :voter_surveys do |t|
      t.boolean :has_attended_firefly
      t.boolean :not_applying_this_year
      t.boolean :will_read
      t.boolean :will_meet
      t.boolean :has_been_voter
      t.boolean :has_participated_other
      t.boolean :has_received_grant
      t.boolean :has_received_other_grant
      t.integer :how_many_fireflies

      t.timestamps
    end
  end
end
