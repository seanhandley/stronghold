require 'test_helper'

class TestModel
  include UserTenantRoleHelper
end

class UserTenantRoleHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end