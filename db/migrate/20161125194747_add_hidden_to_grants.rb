class AddHiddenToGrants < ActiveRecord::Migration[4.2]
  def change
    add_column :grants, :hidden, :boolean, default: false
  end
end
