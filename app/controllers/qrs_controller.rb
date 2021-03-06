require 'vpim/vcard'

class QrsController < ApplicationController
  before_filter :authenticate_user!, :except => [:marketing, :vcard]
  before_filter :check_limit, :only => [:new, :create]

  def index
    @qrs = current_user.qrs.all
  end

  def show
    @qr = Qr.find(params[:id])
  end

  def marketing
    @qr = Qr.find(params[:id])
    redirect_to(edit_qr_path(@qr), :alert => 'Please complete this Hipscan before proceeding') unless @qr.valid?
    respond_to do |format|
      format.html do
        if params[:layout]
          render :layout => params[:layout]
        end
      end
      format.pdf { render :text => PDFKit.new( marketing_qr_url(@qr, :layout => :pdf) ).to_pdf }
    end
  end

  def new
    @qr = current_user.qrs.new
    @qr.name = 'New Hipscan'
    @qr.profile_option = 'url'
    @qr.tagline = "Shop with us.  Connect with us.  Go mobile!"
    @qr.save(false)
    respond_to do |format|
      format.html { redirect_to edit_qr_path(@qr) }
      format.json { render :json => @qr }
    end
  end

  def edit
    @qr = current_user.qrs.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @qr }
    end
  end

  def edit_marketing
    @qr = current_user.qrs.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(edit_qr_path(@qr), :alert => 'Please complete this Hipscan before proceeding') unless @qr.valid? }
      format.json { render :json => @qr }
    end
  end

  #def create
  #  @qr = current_user.qrs.new(params[:qr])
  #
  #  if @qr.save
  #    redirect_to home_path, :notice => 'Hipscan was successfully created.'
  #  else
  #    render :action => "edit"
  #  end
  # end

  def update
    @qr = current_user.qrs.find(params[:id])
    respond_to do |format|    
      if @qr.update_attributes(params[:qr])
        format.html {
          if @qr.parent_qr.present?
            redirect_to(edit_template_path(:qr => @qr.parent_qr.id, :template => @qr.parent_qr.template))
          else
            redirect_to edit_marketing_qr_path(@qr), :notice => 'Hipscan saved.'
          end
        }
        format.json { render :json => { :notice => 'Hipscan saved.'} }
      else
        format.html { render :action => "edit" }
        format.json { render :json => { :notice => 'Hipscan could not be saved' } }
      end
    end
  end

  def update_marketing
    @qr = current_user.qrs.find(params[:id])
    respond_to do |format|
      if @qr.update_attributes(params[:qr])
        format.html{
          redirect_to marketing_qr_path(@qr), :notice => 'Marketing was successfully updated.'
        }
        format.json { render :json => {:notice => 'Error updating Marketing' } }
      else
        format.html { render :action => "edit_marketing" }
        format.json{ render :json => { :notice => 'Error updating Marketing' }, :status => :unprocessable_entity }
      end    
    end
  end

  # DELETE /qrs/1
  # DELETE /qrs/1.xml
  def destroy
    @qr = current_user.qrs.find(params[:id])
    @qr.destroy

    redirect_to home_path
  end

  def color
    @qr = Qr.find(params[:id])
    @qr.qr = nil
    @qr.color = params[:color]
    @qr.save(false)
    @qr.generate_qr
  end

  def vcard
    if @user = User.find_by_username(params[:username])
      card = Vpim::Vcard::Maker.make2 do |maker|
        maker.add_name do |name|
          name.prefix = ''
          name.given = @user.display_name if @user.display_name.present?
        end

        maker.add_tel(@user.phone_number) if @user.phone_number.present?
        maker.add_email(@user.email_address) {|e| e.location = 'work' } if @user.email_address.present?
        maker.add_url(@user.website_url) if @user.website_url.present?
      end

      if request.post?
        Notifier.vcard_email(params[:email], card).deliver
        render :layout => 'hipscan'
      else
        @is_ios = false
        if request.env['HTTP_USER_AGENT'].downcase.index /(iphone|ipad)/
          # render :layout => 'hipscan'
          @is_ios = true
        end
        send_data card.to_s, :filename => 'contact.vcf', :mime_type => "text/x-vcard"
      end
    else
      render :text => 'user not found'
    end
  end

  def analytics
    @qr = current_user.qrs.find(params[:id])
    @scans = @qr.scans(:order => 'created_at DESC').to_a
    @isps = @scans.map{|a| a.isp}.uniq
    @states = @scans.map{|a| a.state}.uniq
    @countries = @scans.map{|a| a.country}.uniq
    @bucket_secret = Digest::MD5.hexdigest("#{APP_CONFIG[:mixpanel_api_secret]}#{current_user.id}")
    render :template => 'home/analytics'
  end

  private

  def check_limit
    if current_user.at_qr_limit?
      redirect_to home_path, :alert => "You are at your maximum QR count"
    end
  end
end
