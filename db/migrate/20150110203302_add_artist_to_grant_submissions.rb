class AddArtistToGrantSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_reference :grant_submissions, :artist, index: true
  end
end
