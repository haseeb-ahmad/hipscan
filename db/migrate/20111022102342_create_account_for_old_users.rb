class CreateAccountForOldUsers < ActiveRecord::Migration
  def self.up
    users = User.find_all_by_account_id nil
    plan = SubscriptionPlan.find_by_name('Basic') 
    users.each do |user|
      account = Account.new
      account.plan = plan
      account.domain = user.username
      account.name = user.username
      account.admin = user
      account.save!
      user.update_attributes :account => account
    end
  end

  def self.down
    
  end
end
