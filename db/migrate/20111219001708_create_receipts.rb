class CreateReceipts < ActiveRecord::Migration
  def self.up
    create_table :receipts do |t|
      t.references :account
      t.string :description
      t.float :amount
      t.string :tracking_id
      t.string :shareasale_user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :receipts
  end
end
