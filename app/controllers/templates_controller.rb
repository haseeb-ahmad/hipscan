class TemplatesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :page]
  before_filter :set_qr, :except => [:new, :create]

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
  
  def new
    @templates_selection = Template.all.map {|t| [t.name, t.id]}
  end
  
  def create
    if request.post?
      qr = current_user.template.present? ? current_user.template : current_user.qrs.new
      qr.profile_option = 'template'
      qr.template = (params['template'].present? ? Template.find(params['template']) : Template.first).template_type
      qr.save(false)
      redirect_to edit_template_path(:qr => qr.id, :template => qr.template)
    end
  end

  def edit
    @template_key = params[:template].downcase.to_sym
    @template = TemplateItem::TEMPLATES[@template_key]
  end

  def update
    @template_key = params[:template].to_sym
    @template = TemplateItem::TEMPLATES[@template_key]

    @qr.update_attribute(:template, @template_key)
    for field in params[:field]
      if field.class == 'String' and field.last.match /^Enter URL for/
        TemplateItem.remove(@qr, @template_key, field.first)
      else
        TemplateItem.set(@qr, @template_key, field.first, field.last)
      end
    end

    redirect_to edit_template_path(:qr => @qr, :template => @qr.template)
  end
  

private

  def set_qr
    @qr = logged_in? ? current_user.template : Qr.find(params[:qr])
  end
end