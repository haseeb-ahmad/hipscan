class AddParentQrToQr < ActiveRecord::Migration
  def self.up
    add_column :qrs, :parent_qr_id, :integer
  end

  def self.down
    remove_column :qrs, :parent_qr_id
  end
end
