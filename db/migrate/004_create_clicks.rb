class CreateClicks < ActiveRecord::Migration
  def self.up
    create_table :clicks do |t|
      t.references :user
      t.string :click_type, :ip, :limit => 16
      t.timestamps
    end

    add_index :clicks, :user_id
    add_index :clicks, [:user_id, :click_type]
  end

  def self.down
    drop_table :clicks
  end
end
