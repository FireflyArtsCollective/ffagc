class CreateVoters < ActiveRecord::Migration[4.2]
  def change
    create_table :voters do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
