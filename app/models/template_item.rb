class TemplateItem < ActiveRecord::Base
  belongs_to :user
  has_attached_file :file

  TEMPLATES = {
      :restaurant => {
          :logo => {
              :field_name => 'Logo',
              :field_type => :file
          },
          :phone_number => {
              :field_name => 'Phone Number',
              :field_type => :string,
              :size => '15',
              :validate_presence => :true,
              :validate_phone => :true
          },
          :about => {
              :field_name => 'About',
              :field_type => :page
          },
          :find_us => {
              :field_name => 'Find Us',
              :field_type => :url,
              :title => 'Enter URL for Google Map directions',
              :size => '80'
          },
          :hours => {
              :field_name => 'Hours of Operation',
              :field_type => :page
          },
          :delivery => {
              :field_name => 'Food Delivery',
              :field_type => :page
          },
          :menu => {
              :field_name => 'Menu',
              :field_type => :string
          },
          :website => {
              :field_name => 'Full Website',
              :field_type => :url,
              :title => 'Enter URL for Website',
              :size => '80'
          },
          :facebook => {
              :field_name => 'Facebook',
              :field_type => :url,
              :title => 'Enter URL for Facebook',
              :size => '80'
          },
          :twitter => {
              :field_name => 'Twitter',
              :field_type => :url,
              :title => 'Enter URL for Twitter',
              :size => '80'
          },
          :specials => {
              :field_name => 'Current Specials',
              :field_type => :page
          },
          :footer => {
              :field_name => 'Footer',
              :field_type => :string,
              :size => '60',
              :validate_presence => :true,
              :validate_phone => :true
          }

      }
  }

  def self.get(qr, template_name, field)
    find_or_create_by_qr_id_and_template_name_and_field_name(qr.id, template_name, field)
  end

  def self.set(qr, template_name, field, value)
    item = find_or_create_by_qr_id_and_template_name_and_field_name(qr.id, template_name, field)
    case item.field_type
      when :string, :url
        item.string_value = value
      when :file
        item.file = value
      when :text, :page
        item.text_value = value
      else
        raise 'TBD'
    end
    item.save
  end


  def template; TEMPLATES[template_name.to_sym]; end
  def field_type; template[field_name.to_sym][:field_type]; end

  def value
    case field_type
      when :string, :url
        string_value
      when :file
        file.file? ? file.url : nil
      when :text, :page
        text_value
      else
        'TBD'
    end
  end


end
