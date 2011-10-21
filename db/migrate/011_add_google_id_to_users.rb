class AddGoogleIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :google_id, :string
  end

  def self.down
    remove_column :users, :google_id
  end
end
