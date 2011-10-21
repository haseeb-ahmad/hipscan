class AddQrIdToScans < ActiveRecord::Migration
  def self.up
    add_column :scans, :qr_id, :integer
  end

  def self.down
    remove_column :scans, :qr_id
  end
end
