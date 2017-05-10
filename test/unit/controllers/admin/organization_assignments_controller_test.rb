require 'test_helper'

class Admin::OrganizationAssignmentsControllerTest < ActionController::TestCase
  setup do
    @organization = Organization.make! state: 'active', reference: STAFF_REFERENCE
    @organization2 = Organization.make! state: 'active'
    @organization3 = Organization.make! state: 'active'

    @user = User.make!(organizations: [@organization])
    @organization.update_attributes self_service: false
    @role = Role.make!(organization: @organization, power_user: true)
    @user.update_attributes(roles: [@role])
    @membership = OrganizationUser.create! organization: @organization3,
                                           user:         @user,
                                           duration:     4
    log_in(@user)
  end

  test 'staff member can temporarily assign themself to an organization' do
    refute @user.organizations.include?(@organization2)
    post :create, params: { id: @organization2.id }
    assert_redirected_to admin_customer_path(@organization2.id)
    assert flash[:notice].length.positive?
    assert_equal 'You have added yourself to this account.', flash[:notice]
    assert @user.organizations.include?(@organization2)
  end

  test 'staff member can remove themself from an organization' do
    assert @user.organizations.include?(@organization3)
    delete :destroy, params: { id: @organization3.id }
    assert_redirected_to admin_customer_path(@organization3.id)
    assert flash[:notice].length.positive?
    assert_equal 'You have removed yourself from this account.', flash[:notice]
    refute @user.organizations.include?(@organization3)
  end

  test 'staff member can restart membership duration timer' do
    time1 = @membership.expires_at
    Timecop.freeze(Time.now + 20.minutes) do
      put :update, params: { id: @organization3.id }
      assert_redirected_to admin_customer_path(@organization3.id)
      assert flash[:notice].length.positive?
      assert_equal 'You have restarted your membership timer.', flash[:notice]
      assert @membership.reload.expires_at > time1
    end
  end

  def teardown
    DatabaseCleaner.clean
  end
end
