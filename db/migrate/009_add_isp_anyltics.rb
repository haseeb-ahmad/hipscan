class AddIspAnyltics < ActiveRecord::Migration
  def self.up
    add_column :scans, :metro_code, :string
    add_column :scans, :area_code, :string
    add_column :scans, :isp, :string
    add_column :scans, :org, :string
  end

  def self.down
    remove_column :scans, :metro_code
    remove_column :scans, :area_code
    remove_column :scans, :isp
    remove_column :scans, :org
  end
end
