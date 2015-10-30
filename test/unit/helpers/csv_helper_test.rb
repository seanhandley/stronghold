require 'test_helper'

class TestModel
  include CsvHelper
end

class CsvHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_foo
    flunk
  end

end