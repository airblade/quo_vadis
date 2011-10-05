class AddAuthenticationToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :username,         :string  # for user identification
    add_column :people, :password_digest,  :string

    add_column :people, :email,            :string  # for forgotten-credentials
    add_column :people, :token,            :string  # for forgotten-credentials
    add_column :people, :token_created_at, :string  # for forgotten-credentials
  end

  def self.down
    remove_column :people, :username
    remove_column :people, :password_digest
    remove_column :people, :email
    remove_column :people, :token
    remove_column :people, :token_created_at
  end
end
