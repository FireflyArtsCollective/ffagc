class AddHiddenToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :hidden, :boolean, default: false
  end
end
