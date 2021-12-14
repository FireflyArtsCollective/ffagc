class AddResetToArtists < ActiveRecord::Migration[4.2]
  def change
    add_column :artists, :reset_digest, :string
    add_column :artists, :reset_sent_at, :datetime
  end
end
