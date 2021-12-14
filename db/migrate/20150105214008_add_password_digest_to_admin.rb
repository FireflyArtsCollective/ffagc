class AddPasswordDigestToAdmin < ActiveRecord::Migration[4.2]
  def change
    add_column :admins, :password_digest, :string
  end
end
