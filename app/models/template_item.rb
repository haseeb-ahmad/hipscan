class TemplateItem < ActiveRecord::Base
  belongs_to :user
  has_attached_file :file

  TEMPLATES = YAML.load_file("#{Rails.root}/config/templates.yml")

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
  
  def self.remove(qr, template_name, field)
    item = find_or_create_by_qr_id_and_template_name_and_field_name(qr.id, template_name, field)
    item.delete
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
