class AddTextToUserDataItem < ActiveRecord::Migration
  def self.up
  	add_column :user_data_items, :text_value, :text
  end

  def self.down
  	remove_column :user_data_items, :text_value
  end
end
