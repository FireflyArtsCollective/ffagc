class AddGrantToGrantSubmissions < ActiveRecord::Migration[4.2]
  def change
    add_reference :grant_submissions, :grant, index: true
  end
end
