require 'test_helper'
 
class CheckCephAccessJobTest < ActiveJob::TestCase

  def setup
    @user = User.make!
    @role = Role.make!
  end

  # def test_enqueued_with_user_commit
  #   assert_enqueued_with(job: CheckCephAccessJob) do
  #     User.make!
  #   end
  # end

  # def test_enqueued_with_role_commit
  #   assert_enqueued_with(job: CheckCephAccessJob) do
  #     @role.users << @user
  #     @role.save!
  #   end
  # end

  # def test_enqueued_with_role_user_commit
  #   assert_enqueued_with(job: CheckCephAccessJob) do
  #     RoleUser.create(user: @user, role: @role)
  #   end
  # end

  def test_inserts_ceph_key_if_user_has_storage_perms
    # CheckCephAccessJob.new.perform(@user)
  end

  def test_removes_ceph_key_if_user_has_no_storage_perms
    # CheckCephAccessJob.new.perform(@user)
  end
end