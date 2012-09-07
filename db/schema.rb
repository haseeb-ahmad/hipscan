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

ActiveRecord::Schema.define(:version => 20120907002835) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_domain"
    t.datetime "deleted_at"
  end

  add_index "accounts", ["full_domain"], :name => "index_accounts_on_full_domain"

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                                 :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 25
    t.string   "guid",              :limit => 10
    t.integer  "locale",            :limit => 1,  :default => 0
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "fk_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_assetable_type"
  add_index "ckeditor_assets", ["user_id"], :name => "fk_user"

  create_table "clicks", :force => true do |t|
    t.integer  "user_id"
    t.string   "click_type",      :limit => 16
    t.string   "ip",              :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "http_user_agent"
    t.string   "carrier"
  end

  add_index "clicks", ["user_id", "click_type"], :name => "index_clicks_on_user_id_and_click_type"
  add_index "clicks", ["user_id"], :name => "index_clicks_on_user_id"

  create_table "links", :force => true do |t|
    t.integer  "qr_id"
    t.string   "url"
    t.string   "device"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "qrs", :force => true do |t|
    t.integer  "user_id"
    t.string   "code"
    t.string   "profile_option"
    t.string   "url"
    t.string   "title"
    t.string   "tagline"
    t.string   "color",              :default => "black"
    t.text     "custom_text"
    t.text     "marketing_text"
    t.string   "logo_file_name"
    t.string   "image_file_name"
    t.string   "logo_content_type"
    t.string   "image_content_type"
    t.string   "qr_file_name"
    t.string   "qr_content_type"
    t.integer  "logo_file_size"
    t.integer  "image_file_size"
    t.integer  "qr_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "video_url"
    t.text     "video_embed"
    t.string   "template"
    t.integer  "qr_id"
    t.integer  "parent_qr_id"
  end

  create_table "receipts", :force => true do |t|
    t.integer  "account_id"
    t.string   "description"
    t.float    "amount"
    t.string   "tracking_id"
    t.string   "shareasale_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saas_admins", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scans", :force => true do |t|
    t.integer  "user_id"
    t.string   "ip"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zipcode"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "http_user_agent"
    t.string   "carrier"
    t.string   "metro_code"
    t.string   "area_code"
    t.string   "isp"
    t.string   "org"
    t.integer  "qr_id"
  end

  add_index "scans", ["user_id"], :name => "index_scans_on_user_id"

  create_table "service_requests", :force => true do |t|
    t.string   "name"
    t.string   "service_type"
    t.string   "email"
    t.string   "industry"
    t.text     "message"
    t.boolean  "read",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_affiliates", :force => true do |t|
    t.string   "name"
    t.decimal  "rate",       :precision => 6, :scale => 4, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  add_index "subscription_affiliates", ["token"], :name => "index_subscription_affiliates_on_token"

  create_table "subscription_discounts", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.decimal  "amount",                 :precision => 6, :scale => 2, :default => 0.0
    t.boolean  "percent"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "apply_to_setup",                                       :default => true
    t.boolean  "apply_to_recurring",                                   :default => true
    t.integer  "trial_period_extension",                               :default => 0
  end

  create_table "subscription_payments", :force => true do |t|
    t.integer  "subscription_id"
    t.decimal  "amount",                    :precision => 10, :scale => 2, :default => 0.0
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "setup"
    t.boolean  "misc"
    t.integer  "subscription_affiliate_id"
    t.decimal  "affiliate_amount",          :precision => 6,  :scale => 2, :default => 0.0
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
  end

  add_index "subscription_payments", ["subscriber_id", "subscriber_type"], :name => "index_payments_on_subscriber"
  add_index "subscription_payments", ["subscription_id"], :name => "index_subscription_payments_on_subscription_id"

  create_table "subscription_plans", :force => true do |t|
    t.string   "name"
    t.decimal  "amount",         :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "renewal_period",                                :default => 1
    t.decimal  "setup_amount",   :precision => 10, :scale => 2
    t.integer  "trial_period",                                  :default => 1
    t.integer  "user_limit"
    t.float    "unit_price"
    t.text     "description"
    t.boolean  "featured",                                      :default => false
  end

  create_table "subscriptions", :force => true do |t|
    t.decimal  "amount",                    :precision => 10, :scale => 2
    t.datetime "next_renewal_at"
    t.string   "card_number"
    t.string   "card_expiration"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                                    :default => "trial"
    t.integer  "subscription_plan_id"
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
    t.integer  "renewal_period",                                           :default => 1
    t.string   "billing_id"
    t.integer  "subscription_discount_id"
    t.integer  "subscription_affiliate_id"
  end

  add_index "subscriptions", ["subscriber_id", "subscriber_type"], :name => "index_subscriptions_on_subscriber"

  create_table "template_items", :force => true do |t|
    t.integer  "qr_id"
    t.string   "template_name"
    t.string   "field_name"
    t.string   "string_value"
    t.integer  "int_value"
    t.float    "float_value"
    t.boolean  "bool_value"
    t.date     "date_value"
    t.time     "time_value"
    t.datetime "timestamp_value"
    t.text     "text_value"
    t.binary   "data_binary"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.string   "page_field_name"
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "template_type"
  end

  create_table "user_data_items", :force => true do |t|
    t.integer  "qr_id"
    t.integer  "user_id"
    t.string   "data_type"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text_value"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                 :limit => 128
    t.string   "encrypted_password",    :limit => 128, :default => "",      :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username",              :limit => 128
    t.string   "foursquare_username"
    t.string   "twitter_username"
    t.string   "spda_username",         :limit => 128
    t.string   "status"
    t.string   "website_url"
    t.string   "website_name"
    t.string   "website_url2"
    t.string   "website_name2"
    t.string   "website_url3"
    t.string   "website_name3"
    t.string   "website_url4"
    t.string   "website_name4"
    t.string   "website_url5"
    t.string   "website_name5"
    t.integer  "facebook_id",           :limit => 8
    t.integer  "foursquare_id",         :limit => 8
    t.integer  "twitter_id",            :limit => 8
    t.string   "linked_in_id"
    t.string   "profile_option"
    t.string   "url"
    t.string   "display_name"
    t.string   "email_address"
    t.string   "phone_number"
    t.string   "facebook_url"
    t.string   "linked_in_profile_url"
    t.text     "custom_text"
    t.string   "photo_file_name"
    t.string   "image_file_name"
    t.string   "photo_content_type"
    t.string   "image_content_type"
    t.string   "qr_file_name"
    t.string   "qr_content_type"
    t.integer  "photo_file_size"
    t.integer  "image_file_size"
    t.integer  "qr_file_size"
    t.datetime "photo_updated_at"
    t.datetime "image_updated_at"
    t.datetime "qr_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "welcome_email_sent"
    t.boolean  "dont_send_email"
    t.string   "color",                                :default => "black"
    t.boolean  "send_sms",                             :default => false
    t.string   "sms_phone_number",      :limit => 32
    t.string   "sms_carrier",           :limit => 32
    t.text     "custom_page"
    t.string   "google_id"
    t.string   "google_profile_id"
    t.string   "account_type",                         :default => "basic"
    t.boolean  "admin",                                :default => false
    t.string   "video_url"
    t.text     "video_embed"
    t.integer  "account_id"
    t.boolean  "account_admin",                        :default => false
    t.string   "description"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id", :unique => true

  create_table "wiki_page_attachments", :force => true do |t|
    t.integer  "page_id",                           :null => false
    t.string   "wiki_page_attachment_file_name"
    t.string   "wiki_page_attachment_content_type"
    t.integer  "wiki_page_attachment_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wiki_page_versions", :force => true do |t|
    t.integer  "page_id",    :null => false
    t.integer  "updator_id"
    t.integer  "number"
    t.string   "comment"
    t.string   "path"
    t.string   "title"
    t.text     "content"
    t.datetime "updated_at"
  end

  add_index "wiki_page_versions", ["page_id"], :name => "index_wiki_page_versions_on_page_id"
  add_index "wiki_page_versions", ["updator_id"], :name => "index_wiki_page_versions_on_updator_id"

  create_table "wiki_pages", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "updator_id"
    t.string   "path"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wiki_pages", ["creator_id"], :name => "index_wiki_pages_on_creator_id"
  add_index "wiki_pages", ["path"], :name => "index_wiki_pages_on_path", :unique => true

end
