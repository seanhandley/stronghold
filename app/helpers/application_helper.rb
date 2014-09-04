module ApplicationHelper

  def display_flash
    flashes = flash.collect do |key,msg|
        content_tag :div, content_tag(:p, h(msg), :class => key), :id => 'flash'
    end.join.html_safe
  end

  def javascript_error_messages_for(obj)
    content_tag(:div, :class => "errors#{obj.id}") { '' }
  end

  def javascript_success_messages_for(obj)
    content_tag(:div, :class => "success#{obj.id}") { '' }
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

  def email_to_display_name(email)
    user = User.find_by email: email
    (user.present? ? user.name : email)
  end

end