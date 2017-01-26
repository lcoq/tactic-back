class AddEncryptedPasswordAndSaltToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :salt, :string, null: false
    add_column :users, :encrypted_password, :string, null: false
  end
end
