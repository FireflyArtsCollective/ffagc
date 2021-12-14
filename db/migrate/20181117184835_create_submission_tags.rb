class CreateSubmissionTags < ActiveRecord::Migration[4.2]
  def change
    create_table :submission_tags do |t|
      t.references :tag, index: true, foreign_key: true
      t.references :grant_submission, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
