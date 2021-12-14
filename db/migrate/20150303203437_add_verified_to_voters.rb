class AddVerifiedToVoters < ActiveRecord::Migration[4.2]
  def change
    add_column :voters, :verified, :boolean
  end
end
