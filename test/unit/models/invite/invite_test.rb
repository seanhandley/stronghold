require 'test_helper'

class TestInvite < CleanTest
  def setup
    @user = User.make! email: 'foo@bar.com'
    @organization = Organization.create(name: 'test-organization')
    @role = @organization.roles.create name: 'foo'
    @invite = Invite.create! organization_id: @organization.id, email: @user.email, roles: [@role]
    @invite2 = Invite.create! organization_id: @organization.id, email: 'user@foo.com', roles: [@role]
  end

  def test_invite_for_existing_user
    mock = MiniTest::Mock.new
    mock.expect(:deliver_later, true)
    Mailer.stub(:membership, mock) do
      Invite.create! organization_id: @organization.id, email: @user.email, roles: [@role]
    end
    mock.verify
  end

  def test_invite_for_new_user
    mock = MiniTest::Mock.new
    mock.expect(:deliver_later, true)
    Mailer.stub(:signup, mock) do
      Invite.create! organization_id: @organization.id, email: 'user@foo.com', roles: [@role]
    end
    mock.verify
  end
end
