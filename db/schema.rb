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

ActiveRecord::Schema.define(version: 20170628062811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "data_indices", force: :cascade do |t|
    t.integer  "scraper_session_id"
    t.string   "index"
    t.string   "value"
    t.string   "change"
    t.string   "percent_change"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "data_market_statuses", force: :cascade do |t|
    t.integer  "scraper_session_id"
    t.string   "last_updated"
    t.string   "total_volume"
    t.string   "total_trades"
    t.string   "total_value"
    t.string   "advances"
    t.string   "declines"
    t.string   "unchanged"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "data_stocks", force: :cascade do |t|
    t.integer  "scraper_session_id"
    t.string   "ticker"
    t.string   "last_updated"
    t.string   "status"
    t.string   "issue_type"
    t.string   "isin"
    t.string   "listing_date"
    t.string   "board_lot"
    t.string   "par_value"
    t.string   "market_capitalization"
    t.string   "outstanding_shares"
    t.string   "listed_shares"
    t.string   "issued_shares"
    t.string   "free_float_level"
    t.string   "foreign_ownership_limit"
    t.string   "sector"
    t.string   "subsector"
    t.string   "last_traded_price"
    t.string   "previous_close_and_date"
    t.string   "change_and_percent_change"
    t.string   "opening_price"
    t.string   "day_high"
    t.string   "day_low"
    t.string   "average_price"
    t.string   "value"
    t.string   "volume"
    t.string   "fifty_two_week_high"
    t.string   "fifty_two_week_low"
    t.string   "pe_ratio"
    t.string   "sector_pe_ratio"
    t.string   "book_value"
    t.string   "pbv_ratio"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",     default: 0, null: false
    t.integer  "attempts",     default: 0, null: false
    t.text     "handler",                  null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "job_metadata"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree
  end

  create_table "scraper_sessions", force: :cascade do |t|
    t.datetime "launched_at"
    t.string   "details"
    t.json     "scraper_service"
    t.text     "data_tables",      default: [],              array: true
    t.string   "run_state"
    t.boolean  "repeat"
    t.json     "performance_data"
    t.json     "status"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "scraper_schedule"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

end
