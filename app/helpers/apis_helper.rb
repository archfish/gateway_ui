module ApisHelper
  def api_methods_options_for_select(selected = nil)
    options_for_select [:GET, :POST, :PATCH, :PUT, :DELETE], selected
  end

  def api_array_to_area_text(v)
    return '' if v.blank?

    v.try(:join, ",\n")
  end

  def api_default_value_html_wrap(obj, tpl = 'default_value[%s]')
    tpl % obj
  end

  def api_kv_line_form_array(v, tpl = '%s[]')
    [
      label_tag(tpl % :name),
      text_field_tag(tpl % :name, v.name),
      label_tag(tpl % :value),
      text_field_tag(tpl % :value, v.value)
    ]
  end
end
