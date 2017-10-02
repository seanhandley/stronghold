require 'test_helper'

class TestMembershipGenerator < CleanTest
 def setup
   @user = User.make!
   @invite = Invite.make!(email: @user.email)
   @power_invite = Invite.make!(:power_user)
   @expired_invite = Invite.make!(:expired)
 end

 def test_refuses_invalid_invites
   membership = MembershipGenerator.new(@expired_invite)
   refute membership.generate!
   assert membership.errors.present?
 end

 def test_organization_matches_invite
   membership = MembershipGenerator.new(@invite)
   membership.generate!
   assert_equal membership.organization.id, @invite.organization.id
 end

 def test_registered_user_has_correct_roles
   membership = MembershipGenerator.new(@invite)
   membership.generate!
   @invite.roles.each do |role|
     assert membership.user.roles.include? role
   end
 end

 def test_membership_marks_invite_as_complete
   VCR.use_cassette('membership_from_invite') do
     membership = MembershipGenerator.new(@invite)
     membership.generate!
     refute membership.invite.can_register?
   end
 end

 def test_membership_cannot_occur_twice
   VCR.use_cassette('membership_from_invite') do
     membership = MembershipGenerator.new(@invite)
     assert membership.generate!
     refute membership.generate!
   end
 end
end
