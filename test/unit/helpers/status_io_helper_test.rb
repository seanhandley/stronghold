require 'test_helper'

class TestModel
  include StatusIoHelper
end

class StatusIoHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end