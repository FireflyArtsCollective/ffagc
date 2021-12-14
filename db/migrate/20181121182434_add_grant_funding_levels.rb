class AddGrantFundingLevels < ActiveRecord::Migration[4.2]
  def change
    add_column :grants, :funding_levels_csv, :string
  end
end
