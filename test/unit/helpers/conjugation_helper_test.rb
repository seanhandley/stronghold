require 'test_helper'

class TestModel
  include ConjugationHelper
end

class ConjugationHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end