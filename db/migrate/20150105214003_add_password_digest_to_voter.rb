class AddPasswordDigestToVoter < ActiveRecord::Migration[4.2]
  def change
    add_column :voters, :password_digest, :string
  end
end
