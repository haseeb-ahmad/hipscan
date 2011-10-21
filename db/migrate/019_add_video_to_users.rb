class AddVideoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :video_url, :string
    add_column :users, :video_embed, :text
    add_column :qrs, :video_embed, :text
  end

  def self.down
    remove_column :users, :video_url
    remove_column :users, :video_embed
    remove_column :qrs, :video_embed
  end
end
