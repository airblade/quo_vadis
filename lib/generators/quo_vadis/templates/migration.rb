class AddAuthenticationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :username,      :string  # for user identification
    add_column :users, :email,         :string  # for sending details to forgetful users
    add_column :users, :password_hash, :string
    add_column :users, :password_salt, :string
  end

  def self.down
    remove_column :users, :username
    remove_column :users, :email
    remove_column :users, :password_hash
    remove_column :users, :password_salt
  end
end
