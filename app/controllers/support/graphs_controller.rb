class Support::GraphsController < SupportBaseController
  skip_authorization_check

  def data
    render json: OrganizationGraphDecorator.new(current_organization).to_json
  end
end
