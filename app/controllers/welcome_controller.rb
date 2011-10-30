class WelcomeController < ApplicationController
  include SMSFu

  def index
    if logged_in?
      flash.keep
      redirect_to home_path
      return
    end
    # @background_image = 'backgrounds/grassbg_white.jpg'
  end

  def contact
    if request.post?
      if params[:message].blank? || params[:email].blank?
        flash[:alert] = 'Message and Email are required'
        return
      end
      Notifier.contact_email(params[:email], params[:message]).deliver
      flash[:notice] = 'Message sent'
      redirect_to :action => :index
    end
  end
  
  def missing_route
    route_not_found
  end
  
  def myhipscan
    unless params[:username]
      redirect_to root_path, :alert => 'No User Specified'
      return
    end
    @user = User.find_by_username(params[:username])
    unless @user
      redirect_to root_path, :alert => "User #{params[:username]} not found"
      return
    end

    add_scan(@user)
    case @user.profile_option
      when 'url'
        redirect_to @user.url
      when 'profile'
      when 'custom_image'
      when 'custom_text'
      else
        redirect_to root_path, :alert => "User #{params[:username]} has not set a profile option"
        return
    end
    render :layout => 'hipscan'
  end

  def click
    @user = User.find(params[:user_id])
    unless params[:noclick]
      @user.clicks.create(:click_type => params[:click_type], :ip => request.remote_ip)
    end
    redirect_to @user.send(params[:click_type])
  end

  def json
    unless params[:username]
      render :json => {:error => 'No username specified'}
      return
    end
    @user = User.find_by_username(params[:username])
    unless @user
      render :json => {:error => "User #{params[:username]} not found"}
      return
    end
    json = {:hipscan => @user.profile_option}
    case @user.profile_option
      when 'url'
        json.merge!(:data => @user.url)
      when 'profile'
        json.merge!(:data => {:display_name => @user.display_name, :email_address => @user.email_address,
                              :phone_number => @user.phone_number, :facebook_url => @user.facebook_url,
                              :twitter_id => @user.twitter_id, :photo => "http://#{HOST}#{@user.photo.url}"})
      when 'custom_image'
        json.merge!(:data => "http://#{HOST}#{@user.image.url}")
      when 'custom_text'
        json.merge!(:data => @user.custom_text)
      else
        json = {:error => "User #{params[:username]} has not set a profile option"}
    end
    render :json => json
  end

  def qr
    size = params[:size] ? params[:size] : 'print'
    if @user = User.find_by_username(params[:username])
      begin
        send_file @user.qr.path(size), :type => 'image/png', :disposition => params[:inline] ? 'inline' : 'attachment'
      rescue
        render :text => 'qr not found -- is the size parameter correct?'
      end
    else
      render :text => 'user not found'
    end
  end

  def getinfo
    if request.post?
      if params[:username].blank? || params[:email].blank? || params[:description].blank?
        flash[:alert] = "Please complete the form"
      else
        Notifier.getinfo_email(params).deliver
        redirect_to services_thankyou_path
      end
    end
  end

  def edit
    if params[:data_content]
      @content = UserDataItem.find_or_create_by_data_type "#{params[:data_content]}-content"
    end
  end

  def update
    content = UserDataItem.find_or_create_by_data_type "#{params[:data_content]}-content" 
    content.text_value = params['user_data_item']['text_value']
    content.save
    flash[:notice] = 'Successfully updated content.'
    redirect_to root_path
    return
  end

  def about
    @content = UserDataItem.find_or_create_by_data_type('about-content').text_value
  end

  def qr_uni
    @title = 'QR University'
    @content = UserDataItem.find_or_create_by_data_type('qr-uni-content').text_value
  end

  def video_services
    if request.post?
      process_request_info_form
    end
  end

  def design_services
    if request.post?
      process_request_info_form
    end
  end

  def mobile_services
    if request.post?
      process_request_info_form
    end
  end

  private

  def process_request_info_form
    if params[:name].blank? || params[:email].blank? || not_email?(params[:email])
      flash[:alert] = "We can not process your request.  <a href='#info_form'>Please check your name and email in the form below.</a>"
    else
      begin
        ServiceRequest.create(:service_type => params[:request_type], :name => params[:name], :email => params[:email], :industry => params[:industry])
        Notifier.services_request_email(params).deliver
        redirect_to services_thankyou_path(:d => params[:request_type])
      rescue
        flash[:alert] = "Sorry. We can not process your request."
      end
    end
  end


end
