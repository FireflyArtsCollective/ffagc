class CreateVotes < ActiveRecord::Migration[4.2]
  def change
    create_table :votes do |t|
      t.integer :score_t
      t.integer :score_c
      t.integer :score_f

      t.timestamps
    end
  end
end
