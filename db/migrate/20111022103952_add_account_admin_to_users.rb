class AddAccountAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :account_admin, :boolean, :default => false
    User.all.each do |user|
      user.account_admin = true
      user.save
    end
  end

  def self.down
    remove_column :users, :account_admin
  end
end