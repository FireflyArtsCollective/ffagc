class CreateGrants < ActiveRecord::Migration[4.2]
  def change
    create_table :grants do |t|
      t.string :name

      t.timestamps
    end
  end
end
