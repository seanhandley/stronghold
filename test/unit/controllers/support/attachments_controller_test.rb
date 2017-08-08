require 'test_helper'

class Support::Api::AttachmentsControllerTest < CleanControllerTest
  setup do
    @user = User.make!(password: 'Password1')
    @organization = @user.primary_organization
    @organization.update_attributes(self_service: false)
    @role = Role.make!(organization: @organization, power_user: true)
    @organization_user = OrganizationUser.find_by(organization: @organization, user: @user)
    @organization_user.update_attributes(roles: [@role])
    log_in(@user)
  end

  test 'can upload attachment' do
    @controller.stub(:check_ticket_ownership, true) do
      @controller.stub(:current_token, 'foo') do
        VCR.use_cassette('sirportly_upload_attachment') do
          post :create, params: {
            ticket_id: 'YQ-232421',
            safe_upload_token: @controller.current_token,
            file: fixture_file_upload('example.txt', 'text/txt')
          }
          assert_response :success
        end
      end
    end
  end
end
