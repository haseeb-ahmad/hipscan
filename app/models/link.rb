class Link < ActiveRecord::Base
  belongs_to :qr

  validates_format_of :url, :with => User::URL, :message => 'does not appear to be a valid url'
end
