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

ActiveRecord::Schema[7.0].define(version: 2026_03_31_000008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "jti", null: false
    t.string "username", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "active_family_group_id"
    t.index ["active_family_group_id"], name: "index_accounts_on_active_family_group_id"
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token", unique: true
    t.index ["email"], name: "index_accounts_on_email", unique: true
    t.index ["jti"], name: "index_accounts_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token", unique: true
    t.index ["username"], name: "index_accounts_on_username", unique: true
  end

  create_table "budgets", force: :cascade do |t|
    t.string "name", null: false
    t.integer "budget_type", default: 0, null: false
    t.decimal "limit", precision: 10, scale: 2
    t.date "start_date"
    t.date "end_date"
    t.bigint "family_group_id"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_budgets_on_account_id"
    t.index ["family_group_id"], name: "index_budgets_on_family_group_id"
    t.check_constraint "family_group_id IS NOT NULL OR account_id IS NOT NULL", name: "budget_must_belong_to_group_or_account"
  end

  create_table "family_group_memberships", force: :cascade do |t|
    t.bigint "family_group_id", null: false
    t.bigint "account_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_family_group_memberships_on_account_id"
    t.index ["family_group_id", "account_id"], name: "index_fgm_on_family_group_and_account", unique: true
    t.index ["family_group_id"], name: "index_family_group_memberships_on_family_group_id"
  end

  create_table "family_groups", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_family_groups_on_owner_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "family_group_id", null: false
    t.bigint "inviter_id", null: false
    t.string "invitation_email", null: false
    t.string "token", null: false
    t.datetime "expiration_date", null: false
    t.boolean "invitation_accepted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["family_group_id", "invitation_email"], name: "index_invitations_on_group_and_email", unique: true
    t.index ["family_group_id"], name: "index_invitations_on_family_group_id"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "transaction_type", default: 0, null: false
    t.bigint "budget_id"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["budget_id"], name: "index_transactions_on_budget_id"
  end

  add_foreign_key "accounts", "family_groups", column: "active_family_group_id"
  add_foreign_key "budgets", "accounts"
  add_foreign_key "budgets", "family_groups"
  add_foreign_key "family_group_memberships", "accounts"
  add_foreign_key "family_group_memberships", "family_groups"
  add_foreign_key "family_groups", "accounts", column: "owner_id"
  add_foreign_key "invitations", "accounts", column: "inviter_id"
  add_foreign_key "invitations", "family_groups"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "budgets"
end
