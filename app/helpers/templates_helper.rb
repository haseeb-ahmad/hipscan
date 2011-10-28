module TemplatesHelper
  def field_type(field)
    @template[field][:field_type]
  end

  def field_tag(field)
    "field[#{field}]"
  end

  def field_name(field)
    @template[field][:field_name]
  end

  def field_title(field)
    @template[field][:title]
  end

  def field_size(field)
    @template[field][:size]
  end

  def field_value(field)
    TemplateItem.get(@qr, @template_key, field).value
  end

  def get_field_content(field)
    @template[field][:content]
  end

  # Field for pages
  def page_field_type(field, page_field)
    get_field_content(field)[page_field][:field_type]
  end

  def page_field_name(field, page_field)
    get_field_content(field)[page_field][:field_name]
  end

  def page_field_tag(field, page_field)
    "page_field[#{field}][#{page_field}]"
  end

  def page_field_title(field, page_field)
    get_field_content(field)[page_field][:title]
  end

  def page_field_size(field, page_field)
    get_field_content(field)[page_field][:size]
  end

  def page_field_value(field, page_field)
    TemplateItem.get(@qr, @template_key, field, page_field).value
  end

  def show_field(field_type, data)

  end
end