class AddMoreDatesToGrants < ActiveRecord::Migration[4.2]
  def change
    rename_column :grants, :start, :submit_start
    rename_column :grants, :end, :submit_end
    add_column :grants, :vote_start, :datetime
    add_column :grants, :vote_end, :datetime
  end
end
