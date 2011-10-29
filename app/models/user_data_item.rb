class UserDataItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :qr

  scope :email_listings, lambda { where(:data_type => 'email_listing')}
end
