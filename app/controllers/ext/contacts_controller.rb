# See http://sirportly.com/docs/admin/advanced-features/customer-data-sources
class Ext::ContactsController < ActionController::Base

  skip_authorization_check

  def find
    if find_params[:type] == "email" && user = User.find_by_email(find_params[:data])
      success UserDecorator.new(user).as_sirportly_data
    else
      fail
    end

  end

  private

  def find_params
    params.require(:contact).permit(:type, :data)
  end

  def fail
    respond_to do |format|
      format.json {
        render json: nil.to_json, status: :not_found    
      }
    end
  end

  def success(user)
    respond_to do |format|
      format.json {
        render json: user.to_json
      }
    end
  end

  def current_user
    nil
  end
end