class Click < ActiveRecord::Base
  belongs_to :user

  def website_url?; self.click_type == 'website_url'; end
  def facebook?; self.click_type == 'facebook'; end
  def twitter?; self.click_type == 'twitter'; end
  def linked_in?; self.click_type == 'linked_in_profil'; end


end
