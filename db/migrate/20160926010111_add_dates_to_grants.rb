class AddDatesToGrants < ActiveRecord::Migration[4.2]
  def change
    add_column :grants, :start, :datetime
    add_column :grants, :end, :datetime
  end
end
