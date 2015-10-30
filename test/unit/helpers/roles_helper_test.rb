require 'test_helper'

class TestModel
  include RolesHelper
end

class RolesHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end