class AddVoterToVote < ActiveRecord::Migration[4.2]
  def change
    add_reference :votes, :voter
  end
end
