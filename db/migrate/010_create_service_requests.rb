class CreateServiceRequests < ActiveRecord::Migration
  def self.up
    create_table :service_requests do |t|
      t.string :name, :service_type, :email, :industry
      t.text :message
      t.boolean :read, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :service_requests
  end
end
