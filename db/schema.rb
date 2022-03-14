# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20220314134033) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string   "name",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "archived",   default: false, null: false
    t.index ["archived"], name: "index_clients_on_archived", using: :btree
    t.index ["name"], name: "index_clients_on_name", unique: true, using: :btree
  end

  create_table "entries", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "title"
    t.datetime "started_at", null: false
    t.datetime "stopped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "project_id"
    t.index ["project_id"], name: "index_entries_on_project_id", using: :btree
    t.index ["user_id"], name: "index_entries_on_user_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "archived",   default: false, null: false
    t.integer  "client_id"
    t.index ["archived"], name: "index_projects_on_archived", using: :btree
    t.index ["client_id"], name: "index_projects_on_client_id", using: :btree
    t.index ["name"], name: "index_projects_on_name", unique: true, using: :btree
  end

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "token",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_sessions_on_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_sessions_on_user_id", using: :btree
  end

  create_table "teamwork_domains", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "name",       null: false
    t.string   "alias",      null: false
    t.string   "token",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alias"], name: "index_teamwork_domains_on_alias", using: :btree
    t.index ["name"], name: "index_teamwork_domains_on_name", using: :btree
    t.index ["user_id"], name: "index_teamwork_domains_on_user_id", using: :btree
  end

  create_table "teamwork_time_entries", force: :cascade do |t|
    t.integer  "entry_id",      null: false
    t.bigint   "time_entry_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["entry_id"], name: "index_teamwork_time_entries_on_entry_id", unique: true, using: :btree
    t.index ["time_entry_id"], name: "index_teamwork_time_entries_on_time_entry_id", unique: true, using: :btree
  end

  create_table "teamwork_user_config_sets", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.json     "set",        default: {}, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["user_id"], name: "index_teamwork_user_config_sets_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",               null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "salt",               null: false
    t.string   "encrypted_password", null: false
    t.json     "configs"
  end

  add_foreign_key "teamwork_domains", "users"
  add_foreign_key "teamwork_time_entries", "entries"
  add_foreign_key "teamwork_user_config_sets", "users"
end
