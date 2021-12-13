class CreateProposals < ActiveRecord::Migration[4.2]
  def change
    create_table :proposals do |t|
      t.string :file
    end
    add_reference :proposals, :grant_submission, index: true
  end
end
