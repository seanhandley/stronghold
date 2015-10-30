require 'test_helper'

class TestModel
  include AuditsHelper
end

class AuditsHelperTest < Minitest::Test
  def setup
    @model = TestModel.new
  end

  def test_audit_detail
    flunk
  end

  def test_audit_colour
    [
      ['create', 'text-success'],
      ['destroy', 'text-danger'],
      ['start', 'text-success'],
      ['stop', 'text-danger'],
      ['gy8gy8b', 'text-info'],
    ].each do |action, colour|
      audit = OpenStruct.new(action: action)
      assert_equal colour, @model.audit_colour(audit)
    end
  end

  def test_try_translate_permissions
    flunk
  end

end