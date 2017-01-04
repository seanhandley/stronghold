class ResetsController < ApplicationController

  layout 'customer-sign-up'

  before_action :check_for_user

  def new ; end

  def create
    @reset = Reset.new(reset_create_params)
    unless @reset.save
      render_errors(@reset) and return
    end
    # Only actually send the mail if it's a real user
    if @reset.user_exists?
      MailJob.perform_later('reset', @reset.id)
    end
    respond_to do |format|
      format.js { render :template => "shared/dialog_success",
                         :locals => {
                            message: "Reset link sent to #{@reset.email}. Please check your email to proceed.",
                            object: Reset.new }
                }
    end
  end

  def show
    reset_session
    @reset = Reset.find_by_token(params[:id])
    slow_404 unless @reset && !@reset.expired?
  end

  def update
    @reset = Reset.find_by_token(params[:id])
    unless @reset && !@reset.expired?
      slow_404
    end

    if @reset.update_password(reset_update_params)
      respond_to do |format|
        format.js {
          javascript_redirect_to sign_in_path  
        }
      end
    else
      render_errors(@reset)
    end
  end

  private

  def reset_create_params
    params.require(:reset).permit(:email)
  end

  def reset_update_params
    params.permit(:password)
  end

  def render_errors(reset)
    respond_to do |format|
      format.js { render :template => "shared/dialog_errors", :locals => {:object => reset}, status: :unprocessable_entity }
    end
  end

  def check_for_user
    raise ActionController::RoutingError.new('Not Found') if current_user
  end

end