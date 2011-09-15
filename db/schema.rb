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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110914142005) do

  create_table "administrators", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albums", :force => true do |t|
    t.string   "name"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pics_count",     :default => 0
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pinyin"
  end

  create_table "comments", :force => true do |t|
    t.integer  "person_id"
    t.text     "content"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "post_id"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "person_id"
    t.boolean  "pending",    :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sharing",    :default => false
    t.boolean  "receiving",  :default => false
  end

  add_index "contacts", ["person_id", "pending"], :name => "index_contacts_on_person_id_and_pending"
  add_index "contacts", ["user_id", "pending"], :name => "index_contacts_on_user_id_and_pending"

  create_table "conversation_visibilities", :force => true do |t|
    t.integer  "conversation_id"
    t.integer  "person_id"
    t.integer  "unread",          :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", :force => true do |t|
    t.string   "subject"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", :force => true do |t|
    t.string   "name"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_comments", :force => true do |t|
    t.integer  "person_id"
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "title"
    t.text     "description"
    t.string   "address"
    t.integer  "subject_id"
    t.boolean  "is_private"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url"
    t.string   "image_url_medium"
    t.string   "image_url_small"
    t.integer  "person_id"
    t.integer  "item_id"
    t.integer  "participants_limit", :default => 100
    t.integer  "location_id"
    t.integer  "group_id",           :default => 0
    t.integer  "status",             :default => 0
    t.string   "status_msg"
    t.integer  "audit_person_id"
    t.integer  "participants_count", :default => 0
    t.integer  "comments_count",     :default => 0
    t.integer  "fans_count",         :default => 0
  end

  create_table "favorites", :force => true do |t|
    t.integer  "person_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "person_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "processed",  :default => false
  end

  create_table "forums", :force => true do |t|
    t.integer  "discussable_id"
    t.string   "discussable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "item_id"
    t.integer  "city_id"
    t.boolean  "is_private"
    t.integer  "join_mode",        :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url_small"
    t.string   "image_url_medium"
    t.string   "image_url_large"
    t.integer  "person_id"
    t.integer  "district_id"
    t.integer  "status",           :default => 0
    t.string   "status_msg"
    t.integer  "audit_person_id"
    t.integer  "members_count",    :default => 0
    t.integer  "events_count",     :default => 0
    t.integer  "topics_count",     :default => 0
  end

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "involvements", :force => true do |t|
    t.integer  "person_id"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_pending", :default => false
  end

  add_index "involvements", ["event_id"], :name => "index_involvements_on_event_id"
  add_index "involvements", ["person_id", "event_id"], :name => "index_involvements_on_person_id_and_event_id", :unique => true
  add_index "involvements", ["person_id"], :name => "index_involvements_on_person_id"

  create_table "items", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url_large"
    t.string   "image_url_medium"
    t.string   "image_url_small"
    t.integer  "category_id",      :default => 1
    t.integer  "fans_count",       :default => 0
    t.integer  "events_count",     :default => 0
    t.integer  "groups_count",     :default => 0
  end

  create_table "locations", :force => true do |t|
    t.integer  "city_id"
    t.integer  "district_id"
    t.string   "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.decimal  "lng",         :precision => 11, :scale => 8
    t.decimal  "lat",         :precision => 11, :scale => 8
  end

  create_table "memberships", :force => true do |t|
    t.integer  "person_id"
    t.integer  "group_id"
    t.boolean  "is_admin",     :default => false
    t.boolean  "pending",      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pending_type", :default => 1
  end

  add_index "memberships", ["group_id"], :name => "index_memberships_on_group_id"
  add_index "memberships", ["person_id", "group_id"], :name => "index_memberships_on_person_id_and_group_id", :unique => true
  add_index "memberships", ["person_id"], :name => "index_memberships_on_person_id"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id"
    t.integer  "person_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notification_actors", :force => true do |t|
    t.integer  "notification_id"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.string   "target_type"
    t.integer  "target_id"
    t.integer  "recipient_id"
    t.string   "type"
    t.integer  "unread",       :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["user_id"], :name => "index_people_on_user_id", :unique => true

  create_table "pic_comments", :force => true do |t|
    t.integer  "pic_id"
    t.integer  "person_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pics", :force => true do |t|
    t.integer  "author_id"
    t.integer  "album_id"
    t.text     "description"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "processed_image"
    t.string   "unprocessed_image"
    t.string   "random_string"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_message_id"
    t.integer  "position"
    t.integer  "comments_count",    :default => 0
  end

  create_table "post_visibilities", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.integer  "author_id"
    t.string   "type"
    t.text     "content"
    t.text     "remote_photo_path"
    t.string   "remote_photo_name"
    t.string   "processed_image"
    t.string   "unprocessed_image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pending",           :default => false
    t.string   "random_string"
    t.integer  "item_id"
    t.integer  "post_d"
  end

  create_table "profiles", :force => true do |t|
    t.string   "name",             :limit => 127
    t.string   "image_url"
    t.string   "image_url_small"
    t.date     "birthday"
    t.string   "gender"
    t.text     "bio"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_url_medium"
    t.integer  "location_id"
    t.text     "hobby"
    t.text     "signature"
  end

  add_index "profiles", ["name"], :name => "index_profiles_on_name"
  add_index "profiles", ["person_id"], :name => "index_profiles_on_person_id"

  create_table "recommendations", :force => true do |t|
    t.integer  "item_id"
    t.integer  "person_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommendations", ["item_id"], :name => "index_recommendations_on_item_id"
  add_index "recommendations", ["person_id", "item_id"], :name => "index_recommendations_on_person_id_and_item_id", :unique => true
  add_index "recommendations", ["person_id"], :name => "index_recommendations_on_person_id"

  create_table "requests", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
  end

  create_table "site_posts", :force => true do |t|
    t.integer  "person_id"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topic_comments", :force => true do |t|
    t.text     "content"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "person_id"
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "person_id"
    t.integer  "forum_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
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
    t.string   "invitation_service"
    t.string   "invitation_identifier"
    t.boolean  "admin",                                 :default => false
    t.datetime "last_request_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["invited_by_id"], :name => "index_users_on_invited_by_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
