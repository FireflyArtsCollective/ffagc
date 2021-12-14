class AddPasswordDigestToArtists < ActiveRecord::Migration[4.2]
  def change
    add_column :artists, :password_digest, :string
  end
end
