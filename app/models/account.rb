class Account < ActiveRecord::Base
  has_many :users
  
  validates_uniqueness_of :account_type, :message => "Account type must be unique"
end
