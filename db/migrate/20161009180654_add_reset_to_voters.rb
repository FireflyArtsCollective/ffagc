class AddResetToVoters < ActiveRecord::Migration[4.2]
  def change
    add_column :voters, :reset_digest, :string
    add_column :voters, :reset_sent_at, :datetime
  end
end
