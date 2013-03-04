require "digest"

class HomeController < ApplicationController
  include SMSFu
  helper SMSFuHelper

  before_filter :authenticate_user!
  before_filter :validate_user_info, :except => [:unsubscribe, :sms]
  before_filter :require_facebook_login, :only => :qr_to_facebook
  before_filter :account_active?, :only => [:index]
  before_filter :check_subscription, :only => [:index]

  def index
    @scan_count = current_user.scans.count
    respond_to do |format|
      format.html
      format.json { render :json => @scan_count }
    end

  end

  def analytics
    @scans = current_user.scans(:order => 'created_at DESC').to_a
    @clicks = current_user.clicks(:order => 'created_at DESC').to_a
    @isps = @scans.map{|a| a.isp}.uniq
    @states = @scans.map{|a| a.state}.uniq
    @countries = @scans.map{|a| a.country}.uniq
    @bucket_secret = Digest::MD5.hexdigest("#{APP_CONFIG[:mixpanel_api_secret]}#{current_user.id}")
  end

  def edit
    @user = current_user
    respond_to do |format|
      format.html
      format.json { render :json => @user }
    end
  end

  def update
    respond_to do |format|
      if current_user.update_attributes(params[:user])
        format.html { redirect_to home_path, :notice => 'Profile updated' }
        format.json { render :json => { :notice => 'Profile updated' } }
        format.xml { render :xml => { :notice => 'Profile updated' } }
      else
        format.html { render :action => :edit }
        format.json { render :json => { :notice => 'Error updating profile' }, :status => :unprocessable_entity }
        format.xml { render :xml => { :notice => 'Error updating profile' } }
     end
    end

#    if current_user.profile_option == 'url' && current_user.url !~ /\b(?:(?:https?|ftp):\/\/|www\.)[-a-z0-9+&@#\/%?=~_|!:,.;]*[-a-z0-9+&@#\/%=~_|]/i
#      @error_msg = 'URL is invalid!'
#      render :action => :edit
#    elsif current_user.profile_option == 'custom_text' && current_user.custom_text.blank?
#      @error_msg = 'Please enter text to display!'
#      render :action => :edit
#    else
#      redirect_to home_path
#    end
  end

  def color
    current_user.qr = nil
    current_user.color = params[:color]
    current_user.save
    current_user.generate_qr
    redirect_to home_path, :notice => 'Hipscan Updated'
  end

  def sms
    if params[:disable]
      current_user.update_attribute(:send_sms, false)
      redirect_to home_path, :message => 'SMS disabled'
    elsif request.put?
      if current_user.update_attributes(params[:user])
        unless current_user.sms_phone_number.blank? || current_user.sms_carrier.blank? || current_user.sms_carrier == 'Please choose a carrier'
          current_user.update_attribute(:send_sms, true)
          redirect_to home_path, :message => 'SMS enabled'
        else
          current_user.errors.add_to_base('Please make sure your Phone Number and Wireless Carrier are correct')
        end
      end
    else
      if current_user.sms_phone_number.blank? && current_user.phone_number
        current_user.sms_phone_number = current_user.phone_number.gsub(/\D/, '')
      end
    end
  end

  def unsubscribe
    current_user.update_attribute(:dont_send_email, :true)
  end

  def qr_to_facebook
    pic_id = graph.put_picture(*current_user.qr.path(:thumb))
#    pic_id = '2044426871454'
#    foo = graph.get_object(pic_id)
#    raise foo.inspect
#    redirect_to "#{foo}?makeprofile=1"
    redirect_to :action => :index, :notice => 'Uploaded'
  end

#  def tweet
#    if twitter.nil?
#      redirect_to :action => :index, :alert => 'No Twitter Session!'
#    elsif params[:text].blank?
#      redirect_to home_path, :alert => 'No Text Specified!'
#    else
#      begin
#        twitter.update(params[:text])
#      rescue
#        redirect_to home_path, :alert => "Tweet error: @{!$}"
#        return
#      end
#      redirect_to home_path, :notice => 'Tweet Sent!'
#    end
#  end
#
#  def wall
#    if graph.nil?
#      redirect_to :action => :index, :alert => 'No Facebook Session!'
#    elsif params[:text].blank?
#      redirect_to home_path, :alert => 'No Text Specified!'
#    else
#      begin
#        graph.put_wall_post(params[:text])
#      rescue
#        redirect_to home_path, :alert => "Facebook error: @{!$}"
#        return
#      end
#      redirect_to home_path, :notice => 'Posted to Wall!'
#    end
#  end

  def analytics_map_data
    @scans = current_user.scans(:order => 'created_at DESC').to_a
    #@isps = @scans.map{|a| a.isp}.uniq
    @states = @scans.map{|a| a.state}.uniq
  end

  def analytics_map_data_world
    @scans = current_user.scans(:order => 'created_at DESC').to_a
    @countries = @scans.map{|a| a.country}.uniq
  end

  def mixpanel
    # /* md5_hash(api_secret + bucket_name) */
    # hashlib.md5(api_secret + bucket).hexdigest()
    @bucket_secret = Digest::MD5.hexdigest("#{APP_CONFIG[:mixpanel_api_secret]}#{current_user.id}")
  end

private
  def account_active?
    unless current_user.account.active?
      unless current_user.subscription_plan == 'Basic'
        flash[:notice] = 'Your plan has expired. Please update your billing details for selected plan or switch to Basic plan'
        redirect_to billing_account_path
        # return false
      end
    end
    return true
  end

  def check_subscription
    subscription = current_user.subscription.subscription_plan.name
    if subscription =~ /^Business/
      if current_user.template.present?
        # redirect_to edit_template_path(:qr => current_user.template.id, :template => current_user.template.template)
        redirect_to templates_path(:qr => current_user.template.id)
        return
      else
        redirect_to new_template_path
        return
      end
    else
      if current_user.profile_option.blank?
        flash.keep
        redirect_to home_edit_path
        return
      end
    end
  end
end
