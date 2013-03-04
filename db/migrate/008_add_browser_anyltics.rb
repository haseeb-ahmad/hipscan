class AddBrowserAnyltics < ActiveRecord::Migration
  def self.up
    add_column :scans, :http_user_agent, :string
    add_column :clicks, :http_user_agent, :string
    add_column :scans, :carrier, :string
    add_column :clicks, :carrier, :string
  end

  def self.down
    remove_column :scans, :http_user_agent
    remove_column :clicks, :http_user_agent
    remove_column :scans, :carrier
    remove_column :clicks, :carrier
  end
end
