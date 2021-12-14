class CreateGrantsVoters < ActiveRecord::Migration[4.2]
  def change
    create_table :grants_voters do |t|
      t.integer :voter_id
      t.integer :grant_id
      t.timestamps
    end
  end
end
