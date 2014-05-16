# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140516010348) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "computers", force: true do |t|
    t.string   "api_key"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "uptime"
  end

  add_index "computers", ["api_key"], name: "index_computers_on_api_key", unique: true, using: :btree

  create_table "disks", force: true do |t|
    t.integer  "computer_id"
    t.string   "name"
    t.integer  "read"
    t.integer  "write"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "timestamp"
  end

  add_index "disks", ["computer_id"], name: "index_disks_on_computer_id", using: :btree

  create_table "interfaces", force: true do |t|
    t.integer  "computer_id"
    t.string   "name"
    t.integer  "rx"
    t.integer  "tx"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "timestamp"
  end

  add_index "interfaces", ["computer_id"], name: "index_interfaces_on_computer_id", using: :btree

  create_table "partitions", force: true do |t|
    t.integer  "computer_id"
    t.string   "name"
    t.decimal  "cap"
    t.decimal  "usage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "timestamp"
  end

  create_table "programs", force: true do |t|
    t.integer  "computer_id"
    t.string   "name"
    t.decimal  "load_usage"
    t.decimal  "memory_usage"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "timestamp"
    t.string   "user"
    t.integer  "read"
    t.integer  "write"
  end

  add_index "programs", ["computer_id"], name: "index_programs_on_computer_id", using: :btree
  add_index "programs", ["timestamp"], name: "index_programs_on_timestamp", using: :btree

  create_table "stats", force: true do |t|
    t.integer  "computer_id"
    t.decimal  "load_average"
    t.decimal  "memory_usage"
    t.decimal  "network_up"
    t.decimal  "network_down"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "timestamp"
  end

  add_index "stats", ["computer_id"], name: "index_stats_on_computer_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "watchdogs", force: true do |t|
    t.integer  "user_id"
    t.integer  "computer_id"
    t.decimal  "cpu_load"
    t.integer  "memory_usage"
    t.integer  "disk_read"
    t.integer  "disk_write"
    t.integer  "rx"
    t.integer  "tx"
    t.integer  "disk_percentage_left"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "watchdogs", ["computer_id"], name: "index_watchdogs_on_computer_id", using: :btree
  add_index "watchdogs", ["user_id"], name: "index_watchdogs_on_user_id", using: :btree

end
