class AddQrIdToQr < ActiveRecord::Migration
  def self.up
    add_column :qrs, :qr_id, :integer
  end

  def self.down
    remove_column :qrs, :qr_id
  end
end
