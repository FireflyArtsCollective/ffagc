class AddArtistRefToArtistSurveys < ActiveRecord::Migration[4.2]
  def change
    add_reference :artist_surveys, :artist, index: true
  end
end
