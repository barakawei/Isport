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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110510123500) do
  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "person_id"
    t.boolean  "pending",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["person_id", "pending"], :name => "index_contacts_on_person_id_and_pending"
  add_index "contacts", ["user_id", "pending"], :name => "index_contacts_on_user_id_and_pending"

  create_table "events", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "title"
    t.text     "description"
    t.string   "location"
    t.integer  "subject_id"
    t.boolean  "ispublic"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["user_id"], :name => "index_people_on_user_id", :unique => true

  create_table "profiles", :force => true do |t|
    t.string   "name",            :limit => 127
    t.string   "image_url"
    t.string   "image_url_small"
    t.date     "birthday"
    t.string   "gender"
    t.text     "bio"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["name"], :name => "index_profiles_on_name"
  add_index "profiles", ["person_id"], :name => "index_profiles_on_person_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",   :null => false
    t.string   "encrypted_password",     :limit => 128, :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "name"
    t.boolean  "getting_started",                       :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
