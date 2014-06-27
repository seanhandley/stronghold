module ApplicationHelper
  def display_flash
    flashes = flash.collect do |key,msg|
        content_tag :div, content_tag(:p, h(msg), :class => key), :id => 'flash'
    end.join.html_safe
  end

  def javascript_error_messages_for(obj)
    content_tag(:div, :class => "errors#{obj.id}") { '' }
  end
end
