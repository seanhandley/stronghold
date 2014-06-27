require 'test_helper'

class TestOrganizationValidations < Minitest::Test
  def setup
    @organization = Organization.make
  end

  def test_valid_by_default
    assert @organization.valid?
  end

  def test_invalid_without_name
    @organization.name = ""
    refute @organization.valid?
  end

  def test_organization_has_unique_reference
    organizations = [@organization.dup, @organization.dup, @organization.dup]
    @organization.save!
    organizations.each(&:save!)

    organizations.collect(&:reference).each_with_index do |o, i|
      assert_equal "#{@organization.reference}#{i+1}", o
    end

    assert Organization.all.collect(&:reference).uniq
  end

  def test_organization_reference_doesnt_change
    @organization.save!
    ref = @organization.reference
    @organization.save!
    assert_equal ref, @organization.reference
  end

  def teardown
    DatabaseCleaner.clean  
  end

end