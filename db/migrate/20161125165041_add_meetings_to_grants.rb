class AddMeetingsToGrants < ActiveRecord::Migration[4.2]
  def change
    add_column :grants, :meeting_one, :datetime
    add_column :grants, :meeting_two, :datetime
  end
end
