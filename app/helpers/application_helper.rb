module ApplicationHelper
  include ERB::Util
  include ActionView::Helpers::TagHelper

  def display_flash
    flashes = flash.collect do |key,msg|
        content_tag :div, content_tag(:p, msg.split('<br>').map{|m| h(m)}.join('<br>').html_safe), :class => "alert alert-#{flash_key_to_bootstrap_class(key)}"
    end.join.html_safe
  end

  def javascript_error_messages_for(obj)
    content_tag(:div, :id => 'js_errors', :class => "hide alert alert-danger errors#{obj.id}") { '' }
  end

  def javascript_success_messages_for(obj)
    content_tag(:div, :id => 'js_successes', :class => "hide alert alert-success success#{obj.id}") { '' }
  end

  def title(page_title)
    content_for(:title) { page_title }
  end

  def body_classes(body_classes)
    content_for(:body_classes) { body_classes.join(' ')}
  end

  def hm(o)
    content_for(:hm) { o }
  end

  def get_model_errors(model)
    errors = model.errors.messages.collect do |field, message|
      {
        "field" => field,
        "message" => message[0]
      }
    end
    return errors
  end

  def flash_key_to_bootstrap_class(key)
    case key
    when "error"
      "danger"
    when "alert"
      "danger"
    when "notice"
      "warning"
    end
  end

end