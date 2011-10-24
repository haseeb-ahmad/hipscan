# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

plans = [{ :name => 'Basic', :amount => 0.0, :setup_amount => 0.0, :renewal_period => 1, :trial_period => 1 }, { :name => 'Product', :amount => 14.0, :setup_amount => 0.0, :renewal_period => 1, :trial_period => 1 }, { :name => 'Business', :amount => 19.0, :setup_amount => 0.0, :renewal_period => 1, :trial_period => 1 }]

SubscriptionPlan.create(plans)

Template.create({:name => 'Restaurant', :template_type => "restaurant"})
Template.create({:name => 'Real Estate', :template_type => 'real_estate'})