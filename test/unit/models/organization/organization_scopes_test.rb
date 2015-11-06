require 'test_helper'

class TestOrganizationScopes < CleanTest
  def setup
    @orgs = [Organization.make!, Organization.make!,
             Organization.make!(test_account: true)]
    Product.make!(:compute)
  end

  def test_all_scope
    assert_equal @orgs.count, Organization.all.count
  end

  def test_billable_scope
    assert_equal (@orgs.count - 1), Organization.billable.count
  end

  def test_cloud_scope
    assert_equal 0, Organization.cloud.count
    o = @orgs.first
    o.products << Product.first
    o.save!
    assert_equal 1, Organization.cloud.count
  end

  def test_active_scope
    assert_equal @orgs.count, Organization.active.count
    @orgs.first.disable!
    assert_equal (@orgs.count - 1), Organization.active.count
  end

  def test_self_service_scope
    assert_equal 3, Organization.self_service.count
    @orgs.first.update_attributes(self_service: false)
    assert_equal 2, Organization.self_service.count
  end

  def test_pending_scope
    assert_equal 0, Organization.pending.count
    @orgs.first.update_attributes(state: OrganizationStates::Fresh)
    assert_equal 1, Organization.pending.count
  end

  def test_frozen_scope
    assert_equal 0, Organization.frozen.count
    @orgs.first.update_attributes(in_review: true)
    assert_equal 1, Organization.frozen.count
  end

end