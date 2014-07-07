class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def javascript_redirect_to(path)
    render js: "window.location.replace('#{path}')"
  end

  def current_section; end
end
