class TemplatesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :page]
  before_filter :set_qr

  def index
  end

  def show
    #@author_mode = true
    @template_key = @qr.template.to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
    render :layout => 'template'
  end

  def page
    #@author_mode = true
    @template_key = params[:template].to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
    @field = params[:field].to_sym
    render :layout => 'template'
  end

  def edit
    @template_key = params[:template].to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
  end

  def update
    @template_key = params[:template].to_sym
    @template = TemplateItem::TEMPLATES[@template_key]

    @qr.update_attribute(:template, @template_key)
    for field in params[:field]
      TemplateItem.set(@qr, @template_key, field.first, field.last)
    end

    redirect_to template_path(@qr)
  end
  

  private

  def set_qr
    @qr = logged_in? ? current_user.qrs.find(params[:qr]) : Qr.find(params[:qr])
  end
end