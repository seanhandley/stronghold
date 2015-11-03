require 'test_helper'

class TestModel
  include AbbreviationHelper
end

class AbbreviationHelperTest < CleanTest
  def setup
    @model = TestModel.new
  end

  def test_fix_abbreviation_case
    test_text = "56 Rams; 1 Ip; With Isp; 5 Gigabytes; 1 Floatingip"
    expected_text = "56 MB RAM; 1 IP; With ISP; 5 GB; 1 Floating IP"
    assert_equal expected_text, @model.fix_abbreviation_case(test_text)
  end

end