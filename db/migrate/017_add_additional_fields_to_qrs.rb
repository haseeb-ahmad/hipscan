class AddAdditionalFieldsToQrs < ActiveRecord::Migration
  def self.up
    add_column :qrs, :name, :string
    add_column :qrs, :video_url, :string
  end

  def self.down
    remove_column :qrs, :name
    remove_column :qrs, :video_url
  end
end
