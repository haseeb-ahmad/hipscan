class TemplatesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :page]
  before_filter :set_qr, :except => [:new, :create]

  def index
    @scan_count = current_user.scans.count
  end

  def show
    #@author_mode = true
    @qr = Qr.find(params[:qr]) if @qr.nil?
    @template_key = @qr.template.to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
    if params[:show_data].present?
      @data = current_user.user_data_items.email_listings
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
    qr.save(false)
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
    require 'csv'

    @data = current_user.user_data_items.email_listings

    csv_string = CSV.generate do |csv|
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
      if params[:email].present?
        data = @qr.user_data_items.new
        data.user = current_user
        data.data_type = 'email_listing'
        data.value = {:email => params[:email], :first_name => params[:first_name], :last_name => params[:last_name]}.to_json
        data.save
        redirect_to params[:redirect_to] if params[:redirect_to].present?
        return
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