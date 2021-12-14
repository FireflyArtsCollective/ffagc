class CreateArtistSurveys < ActiveRecord::Migration[4.2]
  def change
    create_table :artist_surveys do |t|
      t.boolean :has_attended_firefly
      t.string :has_attended_firefly_desc
      t.boolean :has_attended_regional
      t.string :has_attended_regional_desc
      t.boolean :has_attended_bm
      t.string :has_attended_bm_desc
      t.boolean :can_use_as_example

      t.timestamps
    end
  end
end
