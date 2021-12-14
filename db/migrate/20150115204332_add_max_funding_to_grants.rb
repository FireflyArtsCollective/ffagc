class AddMaxFundingToGrants < ActiveRecord::Migration[4.2]
  def change
    add_column :grants, :max_funding_dollars, :integer
  end
end
