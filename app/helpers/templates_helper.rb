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
end
