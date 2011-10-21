class AddGoogleProfileIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :google_profile_id, :string
  end

  def self.down
    remove_column :users, :google_profile_id
  end
end
