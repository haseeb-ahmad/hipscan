class CreateScans < ActiveRecord::Migration
  def self.up
    create_table :scans do |t|
      t.references :user
      t.string :ip, :address, :city, :state, :country, :zipcode
      t.float :latitude, :longitude

      t.timestamps
    end
    add_index :scans, :user_id

  end

  def self.down
    drop_table :scans
  end
end
