class AddSendSmsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_sms, :boolean, :default => false
    add_column :users, :sms_phone_number, :string, :limit => 32
    add_column :users, :sms_carrier, :string, :limit => 32
  end

  def self.down
    remove_column :users, :send_sms
    remove_column :users, :sms_phone_number
    remove_column :users, :sms_carrier
  end
end
