module Ckeditor
  module ViewHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper

    def ckeditor_textarea(object_name, field, options = {})
      options = options.dup.symbolize_keys

      object = options.delete(:object) if options.key?(:object)
      object ||= @template.instance_variable_get("@#{object_name}")

      value = options.delete(:value) if options.key?(:value)
      value ||= object.send(field)

      element_id = options.delete(:id) || ckeditor_element_id(object_name, field, options.delete(:index))
      width  = options.delete(:width) || '100%'
      height = options.delete(:height) || '100%'

      textarea_options = { :id => element_id }

      textarea_options[:cols]  = (options.delete(:cols) || 70).to_i
      textarea_options[:rows]  = (options.delete(:rows) || 20).to_i
      textarea_options[:class] = (options.delete(:class) || 'editor').to_s
      textarea_options[:style] = "width:#{width};height:#{height}"

      ckeditor_options = {:width => width, :height => height }
      ckeditor_options[:language] = (options.delete(:language) || I18n.locale).to_s
      ckeditor_options[:toolbar]  = options.delete(:toolbar) if options[:toolbar]
      ckeditor_options[:skin]     = options.delete(:skin) if options[:skin]

      ckeditor_options[:swf_params] = options.delete(:swf_params) if options[:swf_params]

      ckeditor_options[:filebrowserBrowseUrl] = Ckeditor.file_manager_uri
      ckeditor_options[:filebrowserUploadUrl] = Ckeditor.file_manager_upload_uri

      ckeditor_options[:filebrowserImageBrowseUrl] = Ckeditor.file_manager_image_uri
      ckeditor_options[:filebrowserImageUploadUrl] = Ckeditor.file_manager_image_upload_uri

      output_buffer = ActiveSupport::SafeBuffer.new

      output_buffer << ActionView::Base::InstanceTag.new(object_name, field, self, object).to_text_area_tag(textarea_options.merge(options))

      output_buffer << javascript_tag("function ck_#{element_id}(){if (CKEDITOR.instances['#{element_id}']) {
        CKEDITOR.remove(CKEDITOR.instances['#{element_id}']);}
        CKEDITOR.replace('#{element_id}', { #{ckeditor_applay_options(ckeditor_options)} });}; window.onload=ck_#{element_id}")

      output_buffer
    end

  end

end
