require 'test_helper'

class TestModel
  include DataRepresentationHelper
end

class DataRepresentationHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_r
    assert_equal 'foo', @model.r('foo')
    assert_equal 'none', @model.r([])
    assert_equal 'foo, bar', @model.r(['foo', 'bar'])
  end

end