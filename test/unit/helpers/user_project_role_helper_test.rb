require 'test_helper'

module UserProjectRoleHelperTests
  class TestModel
    include UserProjectRoleHelper

    def project_params
      {
        :name => 'foo',
        :users => Hash[@chosen_users.collect{|u| [u.id, true]}]
      }
    end

    def current_organization
      @org
    end

    def initialize(org, chosen_users)
      @org = org
      @project = org.primary_project
      @chosen_users = chosen_users
    end
  end

  class UserProjectRoleHelperTest < CleanTest
    def setup
      @organization = Organization.make!
      @user1 = User.make!(organizations: [@organization])
      @user2 = User.make!(organizations: [@organization])
    end

    def test_user_project_roles_attributes_both_users_chosen
      @model = TestModel.new(@organization, [@user1, @user2])
      UserProjectRole.stub(:required_role_ids, ["foobarbaz"]) do
        expected = {
          :user_project_roles_attributes =>[
            {:user_id=>@user1.id, :project_id=> @organization.primary_project.id,
             :role_uuid=>"foobarbaz"},
            {:user_id=>@user2.id, :project_id=> @organization.primary_project.id,
             :role_uuid=>"foobarbaz"}
          ]
        }
        assert_equal expected, @model.user_project_roles_attributes
      end
    end

    def test_user_project_roles_attributes_one_user_chosen
      @model = TestModel.new(@organization, [@user1])
      UserProjectRole.stub(:required_role_ids, ["foobarbaz"]) do
        expected = {
          :user_project_roles_attributes =>[
            {:user_id=>@user1.id, :project_id=> @organization.primary_project.id,
             :role_uuid=>"foobarbaz"}
          ]
        }
        assert_equal expected, @model.user_project_roles_attributes
        @model.user_project_roles_attributes.inspect
      end
    end

    def test_user_project_roles_attributes_no_users_chosen
      @model = TestModel.new(@organization, [])
      UserProjectRole.stub(:required_role_ids, ["foobarbaz"]) do
        expected = {
          :user_project_roles_attributes =>[]
        }
        assert_equal expected, @model.user_project_roles_attributes
      end
    end

    def test_user_project_roles_attributes_no_users_chosen_one_removed
      @model = TestModel.new(@organization, [])
      UserProjectRole.stub(:required_role_ids, ["foobarbaz"]) do
        utr = UserProjectRole.create(project_id: @organization.primary_project.id,
                        role_uuid: 'foobarbaz',
                        user_id: @user1.id)
        expected = {
          :user_project_roles_attributes =>[
            {:id=>utr.id.to_s, :_destroy=>"1"}
          ]
        }
        assert_equal expected, @model.user_project_roles_attributes
      end
    end

  end
end
