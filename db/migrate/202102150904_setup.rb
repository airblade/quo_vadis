class Setup < ActiveRecord::Migration[6.0]
  def change
    create_table :qv_accounts do |t|
      t.references :model, polymorphic: true, index: {unique: true}, null: false
      t.string :identifier, index: {unique: true}, null: false
      t.datetime :confirmed_at
      t.timestamps
    end

    create_table :qv_passwords do |t|
      t.references :account, foreign_key: {to_table: :qv_accounts}, null: false
      t.string :password_digest, null: false
      t.timestamps
    end

    create_table :qv_sessions do |t|
      t.references :account, foreign_key: {to_table: :qv_accounts}, null: false
      t.string :ip, null: false
      t.string :user_agent, null: false
      t.datetime :lifetime_expires_at
      t.datetime :last_seen_at
      t.datetime :second_factor_at
      t.timestamps
    end

    create_table :qv_totps do |t|
      t.references :account, foreign_key: {to_table: :qv_accounts}, null: false
      t.string :key, null: false
      t.integer :last_used_at, null: false
      t.timestamps
    end

    create_table :qv_recovery_codes do |t|
      t.references :account, foreign_key: {to_table: :qv_accounts}, null: false
      t.string :code_digest, null: false
      t.timestamps
    end

    create_table :qv_logs do |t|
      t.references :account, foreign_key: {to_table: :qv_accounts}
      t.string :action, null: false
      t.string :ip, null: false
      t.json :metadata, null: false, default: {}
      t.timestamps
    end
  end
end

