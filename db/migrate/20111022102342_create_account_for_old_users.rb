class CreateAccountForOldUsers < ActiveRecord::Migration
  def self.up
    users = User.find_all_by_account_id nil
    plan = SubscriptionPlan.create({ :name => 'Basic', :amount => 0.0, :setup_amount => 0.0, :renewal_period => 1, :trial_period => 1 }) 
    users.each do |user|
      # puts "Username: #{user.username} #{user.id} #{user.url} #{user.twitter_username}"
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
