class AddAuthenticationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :username,         :string  # for user identification
    add_column :users, :password_digest,  :string

    add_column :users, :email,            :string  # for forgotten-credentials
    add_column :users, :token,            :string  # for forgotten-credentials
    add_column :users, :token_created_at, :string  # for forgotten-credentials
  end

  def self.down
    remove_column :users, :username
    remove_column :users, :password_digest
    remove_column :users, :email
    remove_column :users, :token
    remove_column :users, :token_created_at
  end
end
