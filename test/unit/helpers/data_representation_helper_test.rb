require 'test_helper'

class TestModel
  include DataRepresentationHelper
end

class DataRepresentationHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end