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

ActiveRecord::Schema.define(:version => 20130417134658) do

  create_table "artifacts", :force => true do |t|
    t.integer  "deliverable_id"
    t.text     "contents"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "comments", :force => true do |t|
    t.integer  "post_id"
    t.string   "author"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "deliverables", :force => true do |t|
    t.string   "description"
    t.boolean  "completed",         :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "quarter"
    t.text     "approval_comments"
    t.string   "approved_by"
    t.string   "identifier"
    t.boolean  "tech"
    t.boolean  "delta",             :default => true,  :null => false
    t.integer  "lock_version",      :default => 0
  end

  create_table "docs", :force => true do |t|
    t.string   "component"
    t.integer  "maj_version"
    t.integer  "min_version"
    t.string   "dev_stage"
    t.string   "url"
    t.text     "contents"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "created_by"
    t.boolean  "delta",        :default => true,  :null => false
    t.boolean  "deprecated",   :default => false
    t.boolean  "dev",          :default => false
    t.integer  "lock_version", :default => 0
  end

  create_table "guide_sections", :force => true do |t|
    t.integer  "guide_id"
    t.string   "title"
    t.integer  "display_order"
    t.text     "content"
    t.integer  "parent_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "display_url"
    t.string   "created_by"
    t.boolean  "dev",           :default => false
    t.boolean  "delta",         :default => true,  :null => false
    t.integer  "lock_version",  :default => 0
    t.boolean  "published",     :default => true
  end

  create_table "guides", :force => true do |t|
    t.string   "title"
    t.text     "desc"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "url"
    t.boolean  "delta",        :default => true, :null => false
    t.integer  "lock_version", :default => 0
    t.string   "category"
    t.boolean  "published",    :default => true
  end

  create_table "help_links", :force => true do |t|
    t.integer  "tool_id"
    t.string   "title"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "highlights", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.boolean  "dev"
    t.string   "created_by"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.boolean  "delta"
    t.integer  "lock_version", :default => 0
  end

  create_table "invites", :force => true do |t|
    t.string   "email"
    t.boolean  "sent_invite"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "emailed"
  end

  create_table "menu_items", :force => true do |t|
    t.integer  "page_id"
    t.integer  "display_order"
    t.string   "category"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "guide_id"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "content"
    t.boolean  "home_page",    :default => false
    t.boolean  "published",    :default => true
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "created_by"
    t.text     "desc"
    t.string   "category"
    t.boolean  "delta",        :default => true,  :null => false
    t.boolean  "team_page",    :default => false
    t.boolean  "dev",          :default => false
    t.integer  "lock_version", :default => 0
    t.boolean  "landing_page", :default => false
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "content"
    t.string   "author"
    t.boolean  "published",    :default => true
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "lock_version"
    t.boolean  "delta",        :default => true, :null => false
  end

  create_table "server_properties", :force => true do |t|
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "slideshow_items", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "display_order"
  end

  create_table "system_messages", :force => true do |t|
    t.string   "url"
    t.text     "content"
    t.integer  "lock_version",    :default => 0
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "priority",        :default => "general"
    t.datetime "expiration_date"
  end

  create_table "tools", :force => true do |t|
    t.string   "name"
    t.text     "desc"
    t.boolean  "delta",        :default => true, :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "lookup_name"
    t.integer  "lock_version", :default => 0
    t.boolean  "published",    :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "deliverables_admin",     :default => false
    t.boolean  "cms_admin",              :default => false
    t.boolean  "super_admin",            :default => false
    t.string   "username"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

end
