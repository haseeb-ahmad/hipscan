class UserDataItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :qr

  scope :email_listings, lambda { where(:data_type => 'email_listing')}
  scope :sweepstakes, lambda { where(:data_type => 'sweepstakes')}
  scope :messages, lambda { where(:data_type => 'messages').order('created_at DESC') }
end
