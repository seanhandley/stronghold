module ModelErrorsHelper
  def model_errors_as_html(model)
    model.errors.full_messages.join('<br>').html_safe
  end
end
