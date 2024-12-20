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

ActiveRecord::Schema[7.1].define(version: 2024_11_11_222220) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "inventory_checks", force: :cascade do |t|
    t.text "skus"
    t.jsonb "data"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_inventory_checks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "location_id"
    t.string "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "inventory_checks", "users"
end
