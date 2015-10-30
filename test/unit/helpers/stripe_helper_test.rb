require 'test_helper'

class TestModel
  include StripeHelper
end

class StripeHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end