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
    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:deliver_later, true)
    def mock_mailer.apply; true; end

    Mailer.stub :membership, mock_mailer do
      @invite.save
    end
    assert_mock mock_mailer
  end

  def test_invite_for_new_user
    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:deliver_later, true)
    def mock_mailer.apply; true; end

    Mailer.stub :signup, mock_mailer do
      @invite2.save
    end
    assert_mock mock_mailer
  end
end
