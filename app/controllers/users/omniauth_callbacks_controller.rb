require "uri"

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)
    if @user.persisted?
      session[:fb_token] = env["omniauth.auth"]["credentials"]["token"]

#      if session[:fb_redirect] == true
#        session[:fb_redirect] = nil
#        sign_in(@user, :event => :authentication)
#        redirect_to facebook_path
#      else
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
        sign_in_and_redirect @user, :event => :authentication
#      end
    else
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def google
    # You need to implement the method below in your model
    @user = User.find_for_google_oauth(env["omniauth.auth"], current_user)
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

#  def foursquare
#    @user = User.find_for_foursquare_oauth(env["omniauth.auth"], current_user)
#    if @user.persisted?
#      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Foursquare"
#      sign_in_and_redirect @user, :event => :authentication
#    else
#      session["devise.foursquare_data"] = env["omniauth.auth"]
#      redirect_to new_user_registration_url
#    end
#  end

  def twitter
#    raise env["omniauth.auth"].inspect
    @user = User.find_for_twitter_oauth(env["omniauth.auth"], current_user)
    if @user.persisted?
      session[:twitter_token] = env["omniauth.auth"]["credentials"]["token"]
      session[:twitter_secret] = env["omniauth.auth"]["credentials"]["secret"]
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.twitter_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

#  def open_id
#    @user = User.find_for_google_auth(env["omniauth.auth"], current_user)
#    if @user.persisted?
#      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
#      sign_in_and_redirect @user, :event => :authentication
#    else
#      session["devise.google_data"] = env["omniauth.auth"]
#      redirect_to new_user_registration_url
#    end
#  end
#
  def linked_in
    @user = User.find_for_linked_in_oauth(env["omniauth.auth"], current_user)
    if @user.persisted?
      session[:linked_in_token] = env["omniauth.auth"]["credentials"]["token"]
      session[:linked_in_secret] = env["omniauth.auth"]["credentials"]["secret"]
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "LinkedIn"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.linked_in_data"] = env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to new_user_registration_path, :alert => "Could not log you in. #{params[:message]}"
  end
end

