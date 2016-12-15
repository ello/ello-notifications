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

ActiveRecord::Schema.define(version: 20161202220306) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "device_subscriptions", force: :cascade do |t|
    t.string   "platform_device_identifier"
    t.string   "endpoint_arn"
    t.integer  "logged_in_user_id"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sns_application_id"
    t.string   "marketing_version"
    t.string   "build_version"
    t.string   "announcement_subscription_arn"
  end

  add_index "device_subscriptions", ["platform_device_identifier", "sns_application_id"], name: "index_device_subscriptions_on_unique_keys", unique: true, using: :btree
  add_index "device_subscriptions", ["sns_application_id"], name: "index_device_subscriptions_on_sns_application_id", using: :btree

  create_table "sns_applications", force: :cascade do |t|
    t.string   "bundle_identifier"
    t.string   "application_arn"
    t.string   "platform"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "notification_count",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "notify_of_announcements", default: true
  end

end
