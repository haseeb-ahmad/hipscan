class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
#      t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

      t.boolean :welcome_email_sent, :dont_send_email

      t.string :username, :email, :foursquare_username, :twitter_username, :spda_username, :limit => 128
      t.string :status, :website_url, :website_name, :website_url2, :website_name2, :website_url3, :website_name3
      t.string :website_url4, :website_name4, :website_url5, :website_name5

      t.integer :facebook_id, :foursquare_id, :twitter_id, :limit => 8
      t.string :linked_in_id

      t.string :profile_option, :url, :display_name, :email_address, :phone_number, :facebook_url, :twitter_username, :foursquare_username, :linked_in_profile_url
      t.text :custom_text

      t.string :photo_file_name, :image_file_name, :photo_content_type, :image_content_type, :qr_file_name, :qr_content_type
      t.integer :photo_file_size, :image_file_size, :qr_file_size
      t.datetime :photo_updated_at, :image_updated_at, :qr_updated_at

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
#    add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true

    #add_index :users, :fb_id, :unique => true
    add_index :users, :twitter_id, :unique => true

  end

  def self.down
    drop_table :users
  end
end
