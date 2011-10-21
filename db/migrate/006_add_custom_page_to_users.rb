class AddCustomPageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :custom_page, :text
  end

  def self.down
    remove_column :users, :custom_page
  end
end
