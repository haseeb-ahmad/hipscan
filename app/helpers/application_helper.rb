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
end
