require 'test_helper'

class TestModel
  include CardBrandHelper
end

class CardBrandHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end