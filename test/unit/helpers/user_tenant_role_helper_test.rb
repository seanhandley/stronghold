require 'test_helper'

module UserTenantRoleHelperTests
  class TestModel
    include UserTenantRoleHelper

    def tenant_params
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
      @tenant = org.primary_tenant
      @chosen_users = chosen_users
    end
  end

  class UserTenantRoleHelperTest < CleanTest
    def setup
      @organization = Organization.make!
      @user1 = User.make!(organization: @organization)
      @user2 = User.make!(organization: @organization)
    end

    def test_user_tenant_roles_attributes_both_users_chosen
      @model = TestModel.new(@organization, [@user1, @user2])
      UserTenantRole.stub(:required_role_ids, ["foobarbaz"]) do
        expected = {
          :user_tenant_roles_attributes =>[
            {:user_id=>@user1.id, :tenant_id=> @organization.primary_tenant.id,
             :role_uuid=>"foobarbaz"},
            {:user_id=>@user2.id, :tenant_id=> @organization.primary_tenant.id,
             :role_uuid=>"foobarbaz"}
          ]
        }
        assert_equal expected, @model.user_tenant_roles_attributes
      end
    end

    def test_user_tenant_roles_attributes_one_user_chosen
      @model = TestModel.new(@organization, [@user1])
      UserTenantRole.stub(:required_role_ids, ["foobarbaz"]) do
        expected = {
          :user_tenant_roles_attributes =>[
            {:user_id=>@user1.id, :tenant_id=> @organization.primary_tenant.id,
             :role_uuid=>"foobarbaz"}
          ]
        }
        assert_equal expected, @model.user_tenant_roles_attributes
        @model.user_tenant_roles_attributes.inspect
      end
    end

    def test_user_tenant_roles_attributes_no_users_chosen
      @model = TestModel.new(@organization, [])
      UserTenantRole.stub(:required_role_ids, ["foobarbaz"]) do
        expected = {
          :user_tenant_roles_attributes =>[]
        }
        assert_equal expected, @model.user_tenant_roles_attributes
      end
    end

    def test_user_tenant_roles_attributes_no_users_chosen_one_removed
      @model = TestModel.new(@organization, [])
      UserTenantRole.stub(:required_role_ids, ["foobarbaz"]) do
        utr = UserTenantRole.create(tenant_id: @organization.primary_tenant.id,
                        role_uuid: 'foobarbaz',
                        user_id: @user1.id)
        expected = {
          :user_tenant_roles_attributes =>[
            {:id=>utr.id.to_s, :_destroy=>"1"}
          ]
        }
        assert_equal expected, @model.user_tenant_roles_attributes
      end
    end

  end
end
