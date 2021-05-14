# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 202102150904) do

  create_table "people", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "qv_accounts", force: :cascade do |t|
    t.string "model_type", null: false
    t.bigint "model_id", null: false
    t.string "identifier", null: false
    t.datetime "confirmed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier"], name: "index_qv_accounts_on_identifier", unique: true
    t.index ["model_type", "model_id"], name: "index_qv_accounts_on_model_type_and_model_id", unique: true
  end

  create_table "qv_logs", force: :cascade do |t|
    t.bigint "account_id"
    t.string "action", null: false
    t.string "ip", null: false
    t.json "metadata", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_qv_logs_on_account_id"
  end

  create_table "qv_passwords", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_qv_passwords_on_account_id"
  end

  create_table "qv_recovery_codes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "code_digest", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_qv_recovery_codes_on_account_id"
  end

  create_table "qv_sessions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "ip", null: false
    t.string "user_agent", null: false
    t.datetime "lifetime_expires_at"
    t.datetime "last_seen_at"
    t.datetime "second_factor_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_qv_sessions_on_account_id"
  end

  create_table "qv_totps", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "key", null: false
    t.integer "last_used_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_qv_totps_on_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "qv_logs", "qv_accounts", column: "account_id"
  add_foreign_key "qv_passwords", "qv_accounts", column: "account_id"
  add_foreign_key "qv_recovery_codes", "qv_accounts", column: "account_id"
  add_foreign_key "qv_sessions", "qv_accounts", column: "account_id"
  add_foreign_key "qv_totps", "qv_accounts", column: "account_id"
end
