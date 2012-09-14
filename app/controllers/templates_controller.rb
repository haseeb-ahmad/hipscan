if RUBY_VERSION < "1.9" 
  require "faster_csv"
  CSV = FCSV
else
  require "csv"
end

class TemplatesController < ApplicationController
  include SMSFu
  include TemplatesHelper

  helper SMSFuHelper
  
  before_filter :authenticate_user!, :except => [:show, :page, :form]
  before_filter :set_qr, :except => [:new, :create]


  def index
    @scan_count = current_user.scans.count
  end

  def show
    #@author_mode = true
    @qr = Qr.find(params[:qr]) if @qr.nil?
    @template_key = @qr.template.to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
    session.delete :user_data_item_id
    session.delete :user_values

    if params[:show_data].present?
      @data = []
      if @qr.template == 'sweepstakes'
        @data = current_user.user_data_items.sweepstakes
      else
        @data = current_user.user_data_items.email_listings
      end
      render :template => 'templates/show_data'
    else
      render :layout => 'template'
    end
  end

  def page
    #@author_mode = true
    @template_key = params[:template].to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
    @field = params[:field].to_sym
    render :layout => 'template'
  end

  def new

  end

  def multi_url
    if current_user.multi_urls.empty?
      @qr = Qr.new
      @qr.profile_option = 'multi_url'
      @qr.user = current_user
      @qr.save
    else
      @qr = current_user.multi_urls.first
    end

    if request.method == "POST"
      @qr.update_attributes(params[:qr])
      update_links
    end
  end

  def create
    qr = current_user.template.present? ? current_user.template : current_user.qrs.new
    qr.profile_option = 'template'
    qr.template = (params['template'].present? ? Template.find_by_template_type(params['template']) : Template.first).template_type
    qr.save(:validate => false)

    if params['template'] == 'conference'
      qr.reload
      finish_qr = current_user.qrs.new
      finish_qr.profile_option = 'url'
      finish_qr.parent_qr_id = qr.id
      finish_qr.tagline = "Shop with us.  Connect with us.  Go mobile!"
      finish_qr.save(:validate => false)
      finish_qr.reload
      qr.update_attribute :qr_id, finish_qr.id
    end

    redirect_to edit_template_path(:qr => qr.id, :template => qr.template)
  end

  def edit
    @js_content = ''
    @template_key = params[:template].downcase.to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
  end

  def update
    @template_key = params[:template].to_sym
    @template = TemplateItem::TEMPLATES[@template_key]

    @qr.update_attribute(:template, @template_key)
    params[:field].each do |field|
      update_field(field.first, nil, field.last)
    end if params[:field].present?

    params[:page_field].each do |field|
      field.last.each do |page_field|
        update_field(field.first, page_field.first, page_field.last)
      end
    end if params[:page_field].present?

    if params[:complete].present? and params[:complete] == 'true'
      redirect_to templates_path(:qr => @qr)
    else
      redirect_to edit_template_path(:qr => @qr, :template => @qr.template)
    end
  end

  def export
    @data = current_user.user_data_items.email_listings

    csv_string = CSV.generate({}) do |csv|
      csv << ['First Name', 'Last Name', 'Email']

      @data.each do |user|
        data = JSON(user.value)
        csv << [data['first_name'], data['last_name'], data['email']]
      end
    end

    send_data csv_string, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=users_list.csv"
  end

  def form
    if request.post?
      if params[:email].present? and @qr.template != 'sweepstakes'
        data = @qr.user_data_items.new
        data.user = @qr.user
        data.data_type = 'email_listing'
        data.value = {:email => params[:email], :first_name => params[:first_name], :last_name => params[:last_name], :phone_number => params[:phone_number], :phone_carrier => params[:phone_carrier]}.to_json
        if data.save 
          if @qr.template == 'university' || @qr.template == 'conference'
            recipient = @qr.template_items.find_by_field_name('recipient').string_value
            recipient = @qr.user.email unless recipient.present?

            event = @qr.template_items.find_by_field_name('event_name').string_value

            Notifier.university_signup(recipient, event, data).deliver 
            Notifier.university_confirmation(params[:email], event, data).deliver 
          end
        end
        redirect_to params[:redirect_to] if params[:redirect_to].present?
        return
      end


      if @qr.template == 'sweepstakes'
        if session[:user_data_item_id].present?
          data = @qr.user_data_items.where(:id => session[:user_data_item_id]).first

          values = {:email => params[:email], :first_name => params[:first_name], :last_name => params[:last_name], :phone_number => params[:phone_number], :phone_carrier => params[:phone_carrier]}
          if session[:user_values].present?
            values.merge!(session[:user_values])
          end

          data.value = values.to_json
          if data.save
            session.delete :user_data_item_id
            session.delete :user_values
            redirect_to params[:redirect_to] if params[:redirect_to].present?
            return
          end

        else
          data = @qr.user_data_items.new
          data.user = @qr.user
          data.data_type = 'sweepstakes'

          values = {}

          @template_key = 'sweepstakes'
          @template = TemplateItem::TEMPLATES[:sweepstakes]
          values[:question1] = page_field_value(:quiz, params[:question1].to_sym) if params[:question1].present?
          values[:question2] = page_field_value(:quiz, params[:question2].to_sym) if params[:question2].present?
          values[:question3] = page_field_value(:quiz, params[:question3].to_sym) if params[:question3].present?
          if data.save
            session[:user_data_item_id] = data.id
            session[:user_values] = values
            redirect_to params[:redirect_to] if params[:redirect_to].present?
            return
          end
        end

      end
    end

    render :text => 'Success!'
  end

  def destroy
    if params[:template_item].present?
      item = @qr.template_items.find(params[:template_item])
      item.destroy if item.present?
    end
    respond_to do |format|
      format.js   { render :nothing => true }
    end
  end

  def message
    if request.post? and params[:content_message].present?
      @data = []
      if @qr.template == 'sweepstakes'
        @data = current_user.user_data_items.sweepstakes
      else
        @data = current_user.user_data_items.email_listings
      end

      subscriber_list = []
      sms = SMSFu::Client.configure(:delivery => :pony, :pony_config => PONY_CONFIG)
      @data.each do |subscriber|
        if subscriber.value.present?
          data = JSON(subscriber.value)
          if data['phone_number'].present? && data['phone_carrier'].present?
            begin
              sms.deliver(data['phone_number'], data['phone_carrier'], params[:content_message], :from => "4154799559")
              subscriber_list << subscriber.id
              Rails.logger.info "Send SMS to #{user.sms_phone_number}"
            rescue

            end
          end
        end
      end

      values = {:content => params[:content_message], 
                :subscriber_list => subscriber_list, 
                :created_at => Time.now, 
                :recipient_count => subscriber_list.count }

      data = @qr.user_data_items.new
      data.user = @qr.user
      data.data_type = 'messages'
      data.value = values.to_json
      data.save

      flash[:notice] = "Your have successfully sent SMS to your subscribers."
    else
      @data = current_user.user_data_items.messages
    end
  end


private
  def update_field(field, page_field = nil, value = nil)
    if field.class == 'String' and field.last.match /^Enter URL for/
      TemplateItem.remove(@qr, @template_key, field.first, page_field)
    else
      TemplateItem.set(@qr, @template_key, field, page_field, value)
    end
  end

  def update_links
    if params['iphone'].present? and params['iphone_check'].present?
      @qr.iphone_link.update_attribute :url, params['iphone']
    else
      @qr.iphone_link.update_attribute :url, nil
    end

    if params['android'].present? and params['android_check'].present?
      @qr.android_link.update_attribute :url, params['android']
    else
      @qr.android_link.update_attribute :url, nil
    end

    if params['blackberry'].present? and params['blackberry_check'].present?
      @qr.blackberry_link.update_attribute :url, params['blackberry']
    else
      @qr.blackberry_link.update_attribute :url, nil
    end
  end

  def set_qr
    @qr = logged_in? ? current_user.template : Qr.find(params[:qr])
  end
end