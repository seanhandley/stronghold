require 'test_helper'

class TestModel
  include OpenstackPathHelper
end

class OpenstackPathHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end