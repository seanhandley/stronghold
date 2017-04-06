require 'test_helper'

class Support::ChangeOrganizationsControllerTest < CleanControllerTest
  setup do
    @user = User.make!
    @active_org = Organization.make! state: 'active'
    @active_org2 = Organization.make! state: 'active'
    @frozen_org = Organization.make! state: 'frozen'
    @fresh_org = Organization.make! state: 'fresh'
    @closed_org = Organization.make! state: 'closed'
    @forbidden_org = Organization.make! state: 'active'
    @user.organizations << @active_org << @active_org2 << @frozen_org << @fresh_org
    log_in(@user)
  end

  test 'user can change organizations' do
    old = session[:organization_id]
    put :change, params: { organization_id: @active_org2.id}
    assert_redirected_to support_root_path
    assert flash[:notice].length > 0
    assert_equal 'Account changed successfully.', flash[:notice]
    refute_equal old, session[:organization_id]
  end

  test 'user can change organizations to a frozen account' do
    old = session[:organization_id]
    put :change, params: { organization_id: @frozen_org.id}
    assert_redirected_to support_root_path
    assert flash[:notice].length > 0
    refute_equal old, session[:organization_id]
  end

  test 'user can change organizations to a fresh account' do
    old = session[:organization_id]
    put :change, params: { organization_id: @fresh_org.id}
    assert_redirected_to support_root_path
    assert flash[:notice].length > 0
    refute_equal old, session[:organization_id]
  end

  test "user can't change organizations to an organization they do not belong to" do
    old = session[:organization_id]
    refute @user.organizations.include?(@forbidden_org)
    put :change, params: { organization_id: @forbidden_org.id}
    assert_redirected_to support_root_path
    assert_equal "Action not allowed.", flash[:alert]
    assert_equal old, session[:organization_id]
  end
end
