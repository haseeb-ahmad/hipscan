class WikiPagesController < ApplicationController

  acts_as_wiki_pages_controller

  def edit_allowed?
  	logged_in? and current_user.admin?
  end

  def history_allowed?
  	logged_in? and current_user.admin?
  end
end
