class AddActivationToAdmins < ActiveRecord::Migration[4.2]
  def change
    add_column :admins, :activation_digest, :string
    add_column :admins, :activated, :boolean, default: false
    add_column :admins, :activated_at, :datetime
  end
end
