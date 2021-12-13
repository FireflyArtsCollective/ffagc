class AddContactZipcodeToArtists < ActiveRecord::Migration[4.2]
  def change
    add_column :artists, :contact_zipcode, :string
  end
end
