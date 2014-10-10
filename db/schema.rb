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

ActiveRecord::Schema.define(version: 20141009154152) do

  create_table "authorizations", force: true do |t|
    t.integer  "user_id"
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.text     "token"
    t.text     "secret"
    t.text     "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "authorizations", ["user_id"], name: "index_authorizations_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",   default: 0
    t.string   "commentable_type"
    t.string   "title"
    t.text     "body"
    t.string   "subject"
    t.integer  "user_id",          default: 0, null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "commits", force: true do |t|
    t.text     "note"
    t.integer  "goal_id",                 null: false
    t.integer  "user_id",                 null: false
    t.integer  "state",      default: 0,  null: false
    t.datetime "starts_at",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reminded",   default: -1
    t.string   "photo"
    t.string   "checked_by"
    t.datetime "checked_at"
  end

  add_index "commits", ["goal_id"], name: "index_commits_on_goal_id", using: :btree
  add_index "commits", ["user_id"], name: "index_commits_on_user_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deposits", force: true do |t|
    t.string   "source",                     null: false
    t.string   "payer"
    t.string   "token",                      null: false
    t.integer  "goal_id",                    null: false
    t.integer  "user_id",                    null: false
    t.integer  "amount_cents",               null: false
    t.integer  "state",          default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payer_id"
    t.string   "transaction_id"
  end

  create_table "follows", force: true do |t|
    t.integer  "followable_id",                   null: false
    t.string   "followable_type",                 null: false
    t.integer  "follower_id",                     null: false
    t.string   "follower_type",                   null: false
    t.boolean  "blocked",         default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followable_id", "followable_type"], name: "fk_followables", using: :btree
  add_index "follows", ["follower_id", "follower_type"], name: "fk_follows", using: :btree

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "goal_activities", force: true do |t|
    t.string   "activeable_type"
    t.integer  "activeable_id"
    t.integer  "goal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goals", force: true do |t|
    t.string   "title",                       null: false
    t.text     "description"
    t.string   "timezone",                    null: false
    t.text     "schedule_yaml"
    t.integer  "user_id",                     null: false
    t.integer  "state",         default: 0,   null: false
    t.string   "weekdays"
    t.string   "interval",      default: "1", null: false
    t.string   "interval_unit",               null: false
    t.datetime "start_time"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "weektimes"
    t.integer  "duration",                    null: false
    t.integer  "occurrence"
    t.string   "legend"
    t.string   "type"
    t.string   "hash_tag"
    t.integer  "privacy",       default: 10
    t.string   "checkin_with"
    t.integer  "starts",        default: 1
    t.string   "duration_desc"
  end

  add_index "goals", ["user_id"], name: "index_goals_on_user_id", using: :btree

  create_table "mention_pointers", force: true do |t|
    t.integer  "twitter",    limit: 8, default: 1
    t.integer  "facebook",   limit: 8, default: 722859861120858
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.string   "notifyable_type"
    t.integer  "notifyable_id"
    t.integer  "user_id",                         null: false
    t.boolean  "read",            default: false
    t.string   "event"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reminders", force: true do |t|
    t.text     "type",                     null: false
    t.string   "recipient",                null: false
    t.string   "recipient_id",             null: false
    t.integer  "state",        default: 1, null: false
    t.integer  "user_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reminders", ["user_id"], name: "index_reminders_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "avatar"
    t.string   "display_name"
    t.string   "username"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "timezone"
    t.string   "checkin_with"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
