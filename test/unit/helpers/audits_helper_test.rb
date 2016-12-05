require 'test_helper'

class TestModel
  include AuditsHelper
  include DataRepresentationHelper
end

class AuditsHelperTest < CleanTest
  def setup
    @model = TestModel.new
    @organization = Organization.make!
  end

  def test_audit_detail
    assert_equal "'Name': '#{@organization.name}', 'Time zone': 'London', 'Locale': 'en', 'Billing address 1': '', 'Billing address 2': '', 'Billing city': '', 'Billing postcode': '', 'Billing country': '', 'Phone': '', 'Billing contact': '', 'Technical contact': ''.", @model.audit_detail(@organization.audits.first)
    old_name = @organization.name
    @organization.update_attributes(name: 'foo')
    assert_equal "Name is now 'foo' (was '#{old_name}').", @model.audit_detail(@organization.audits.last)
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
    assert_equal 'Can modify roles and invite users', @model.try_translate_permissions(:permissions, 'roles.modify')
    assert_equal 'blorbs.modify', @model.try_translate_permissions(:permissions, 'blorbs.modify')
  end

end