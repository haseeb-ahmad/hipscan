class CreateUserDataItems < ActiveRecord::Migration
  def self.up
    create_table :user_data_items do |t|
      t.references :qr
      t.references :user
      t.string :data_type
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :user_data_items
  end
end
