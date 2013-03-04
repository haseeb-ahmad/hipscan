class AddMissingFieldsToSubscriptionPlan < ActiveRecord::Migration
  def self.up
  	#add_column :subscription_plans, :user_limit, :integer
  	#add_column :subscription_plans, :unit_price, :float
  	#add_column :subscription_plans, :description, :text
  	#add_column :subscription_plans, :featured, :boolean, :default => false
  end

  def self.down
  	#remove_column :subscription_plans, :user_limit
  	#remove_column :subscription_plans, :user_price
  	#remove_column :subscription_plans, :description
  	#remove_column :subscription_plans, :featured

  end
end
