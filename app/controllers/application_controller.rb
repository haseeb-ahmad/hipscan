class ApplicationController < ActionController::Base

  protect_from_forgery

  helper_method :logged_in?, :admin?
  helper_method :facebook_logged_in?, :current_facebook_user, :graph, :facebook_friends


# These are bugged in Rails 3.0 -- see last item in routes.rb
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  rescue_from ActionController::RoutingError, :with => :route_not_found

  protected

  def route_not_found
#    raise request.inspect
    username = params[:username] if params[:username].present?
    username ||= request.env['REQUEST_URI'].split('?').first.gsub('/','').downcase
#    raise request.env['action_dispatch.request.parameters']['noscan'].inspect

    if @user = User.find_by_username(username)
      add_scan(@user)
      if @user.profile_url?
        redirect_to @user.url
      elsif @user.profile_video? && @user.video_url.present?
        redirect_to @user.video_url
      else
        render :template => 'welcome/myhipscan', :layout => 'hipscan'
      end
    elsif @qr = Qr.find_by_code(username)
      @user = @qr.user
      add_scan(@user, @qr)

      if @qr.template
        redirect_to template_path(@qr)
      elsif @qr.profile_url?
        redirect_to @qr.url
      elsif @qr.video? && @qr.video_url.present?
        redirect_to @qr.video_url
      else
        render :template => 'qrs/show', :layout => 'hipscan'
      end
    else
      render :file => File.join(Rails.root, 'public', '404.html'), :status => 404
    end
  end


  def validate_user_info
    if user_signed_in? && !current_user.user_valid?
      flash.keep
      redirect_to edit_user_registration_path
    end
  end

  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(Rails.root, 'public', '404.html'), :status => 404
  end

  private
  
  def admin_authenticate
    unless admin?
      flash[:notice] = "You don't have rights to access this page."
      redirect_to root_path 
    end
    return
  end

  def logged_in?
    user_signed_in? ? true : false
  end

  def admin?
     user_signed_in? && current_user.admin?
  end
  
  def account_admin?
    user_signed_in? and current_user.account_admin?
  end

  def require_facebook_login
    unless logged_in? && facebook_logged_in?
      session[:fb_redirect] = true
      redirect_to user_omniauth_authorize_path(:facebook)
    end
  end

  def facebook_logged_in?
    graph ? true : false
  end
  
  def current_facebook_user
    facebook_logged_in? ? (@fb_user ||= graph.get_object("me")) : nil
  end
  
  def graph
    session[:fb_token] ? (@graph ||= Koala::Facebook::GraphAPI.new(session[:fb_token])) : nil?
  end
  def facebook_friends
    facebook_logged_in? ? (@fb_friends ||= graph.get_connections("me", "friends")) : []
  end

  def add_scan(user, qr = nil)
    begin
      unless request.env['action_dispatch.request.parameters']['noscan'] || (logged_in? && current_user == user)
        #unless user.scans.find_by_ip(request.remote_ip, :conditions => ['created_at > ?', DateTime.now - 15.minutes])
          scan = user.scans.create(:ip => request.remote_ip, :http_user_agent => request.env['HTTP_USER_AGENT'], :qr => qr)
          scan.location
          track('scan', {'token' => APP_CONFIG[:mixpanel_token],
                         'bucket' => @user.id,
                         'ip' => scan.ip,
                         'mobile_device' => scan.mobile_device,
                         'country' => scan.country,
                         'state' => scan.state,
                         'zipcode' => scan.zipcode,
                         'metro_code' => scan.metro_code,
                         'area_code' => scan.area_code,
                         'isp' => scan.isp,
                         'org' => scan.org,
                         'qr' => qr ? qr.id : nil,
                         'scan_type' => @user.profile_option})
          Rails.logger.info "Mixpanel Scan #{scan.id}"
          if user.send_sms
            scan.geocode
            msg = scan.city.blank? ? "You've been scanned at Hipscan.com!" :  "You've been scanned!  Your latest Hipscan just came through from #{scan.location}"
            sms = SMSFu::Client.configure(:delivery => :pony, :pony_config => PONY_CONFIG)
            sms.deliver(user.sms_phone_number, user.sms_carrier, msg, :from => "4154799559")
            Rails.logger.info "Send SMS to #{user.sms_phone_number}"
          end

        #end
      end
    rescue
      Rails.logger.fatal $!
      #Rails.logger.fatal $@
    end
  end

  def track(event, properties={})
    if !properties.has_key?("token")
      raise "Token is required"
    end
    params = {"event" => event, "properties" => properties}
    data = ActiveSupport::Base64.encode64s(JSON.generate(params))
    request = "http://api.mixpanel.com/track/?data=#{data}"
    `curl -s '#{request}' &`
  end

  def not_email?(e)
    e !~ /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
  end

end
