require 'test_helper'

class TestModel
  include CardBrandHelper
end

class CardBrandHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_brand_to_font_awesome
    assert_equal 'visa', @model.brand_to_font_awesome('VISA')
    assert_equal 'mastercard', @model.brand_to_font_awesome('MasterCard')
    assert_equal 'amex', @model.brand_to_font_awesome('American Express')
  end

end