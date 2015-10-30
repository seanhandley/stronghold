require 'test_helper'

class TestModel
  include TicketsHelper
end

class TicketsHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end