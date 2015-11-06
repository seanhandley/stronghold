require 'test_helper'

class TestModel
  include TicketsHelper
end

class TicketsHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_markdown
    assert_equal "<p>foo</p>\n", @model.markdown('foo')
  end

  def test_markdown_bad_input
    boom = OpenStruct.new
    assert_equal boom, @model.markdown(boom)
  end

end