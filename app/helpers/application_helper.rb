module ApplicationHelper

  def hipscan(append = '')
    raw "<span class='hipscan'>Hipscan#{append}</span>"
#    capture_haml do
#      haml_tag 'span>', :class => 'hipscan' do
#        haml_concat 'Hipscan'
#      end
#    end
  end

# Doesnt work in IE
#  def barcode(text = 'hipscan')
#    text = 'hipscan' if text.blank?
#    qr = RQRCode::QRCode.new(text, :size => 4, :level => :h )
#    capture_haml do
#      haml_tag :div, :class => 'qr', :title => text do
#        haml_tag :table do
#          qr.modules.each_index do |x|
#            haml_tag :tr do
#              qr.modules.each_index do |y|
#                haml_tag :td, :class => qr.is_dark(x,y) ? 'black' : 'white' do
#                  haml_concat '&nbsp;'
#                end
#              end
#            end
#          end
#        end
#      end
#    end
#  end

  def barcode(text = 'http://hipscan.com', sz = 8, div = 'hipscan-qrcode')
    text = 'http://hipscan.com' if text.blank?
    capture_haml do
      haml_tag :div, :class => 'qr', :title => text do
        haml_concat raw qrcode(text, sz, 6, div)
      end
    end
  end
  
  def flash_notices
    raw([:notice, :error, :alert].collect {|type| content_tag('div', flash[type], :id => type) if flash[type] }.join)
  end
  
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    raw(content_tag(:div, content_tag(:div, link_to(label, 'javascript: $("form").submit();', :style => 'display: inline-block; font-size: 14px'), :class => 'signup-button', :style => 'display: inline-block;margin-top: 15px') + ' or ' + link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit'))
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, :precision => 0) : number_to_currency(discount.amount)) + ' off'
  end
  
end
