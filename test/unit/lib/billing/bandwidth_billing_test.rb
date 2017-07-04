require 'test_helper'

class TestBandwidthBilling < CleanTest
  def setup
    @rate_a = 0.06
    @rate_b = 0.05
    @rate_c = 0.04
    @from = Time.now - 1.month
    @to = Time.now
    @project_id = "foo"
  end

  def test_cost_sub_10_tb
    gb = 1024
    costs = Billing::Bandwidths.cost(gb)
    assert_equal @rate_a * gb,   costs[:rate_a]
    assert_equal 0,              costs[:rate_b]
    assert_equal 0,              costs[:rate_c]

    gb = 2048
    costs = Billing::Bandwidths.cost(gb)
    assert_equal @rate_a * gb, costs[:rate_a]
    assert_equal 0,            costs[:rate_b]
    assert_equal 0,            costs[:rate_c]

    gb = 10240
    costs = Billing::Bandwidths.cost(gb)
    assert_equal @rate_a * gb,  costs[:rate_a]
    assert_equal 0,             costs[:rate_b]
    assert_equal 0,             costs[:rate_c]
  end

  def test_cost_10_to_50_tb
    costs = Billing::Bandwidths.cost(10240 + 1024)
    assert_equal @rate_a * 10240, costs[:rate_a]
    assert_equal @rate_b * 1024,  costs[:rate_b]
    assert_equal 0,               costs[:rate_c] 

    costs = Billing::Bandwidths.cost(10240 + (1024 * 40))
    assert_equal @rate_a * 10240,        costs[:rate_a]
    assert_equal @rate_b * (1024 * 40),  costs[:rate_b]
    assert_equal 0,                      costs[:rate_c] 
  end

  def test_cost_plus_50_tb
    costs = Billing::Bandwidths.cost(10240 + (1024 * 40) + 1024)
    assert_equal @rate_a * 10240,        costs[:rate_a]
    assert_equal @rate_b * (1024 * 40),  costs[:rate_b]
    assert_equal @rate_c * 1024,         costs[:rate_c] 
  end

  def test_total
    costs = Billing::Bandwidths.cost(10240 + (1024 * 40) + 1024)
    assert_equal [costs[:rate_a], costs[:rate_b], costs[:rate_c]].sum,
                  costs[:total]
  end

  def test_usage_case_full_period_one_address
    Billing::Ip.create! address: '1.2.3.4', project_id: @project_id,
                       ip_type: 'ip.floating', recorded_at: Time.now - 4.months,
                       ip_id: 'foobar'
    Billing::Bandwidths.stub(:bytes, 6 * (1024 ** 3), ['1.2.3.4', @from, @to]) do
      usage = Billing::Bandwidths.gigabytes_for_project(@project_id, @from, @to)
      assert_equal 6, usage
    end
  end

  def test_usage_case_full_period_two_addresses
    Billing::Ip.create! address: '1.2.3.4', project_id: @project_id,
                   ip_type: 'ip.floating', recorded_at: Time.now - 4.months,
                   ip_id: 'foobar'
    Billing::Ip.create! address: '4.3.2.1', project_id: @project_id,
                       ip_type: 'ip.floating', recorded_at: Time.now - 4.months,
                       ip_id: 'foobarbaz'
    results =  ->(address, _,_) {
      case address
      when '1.2.3.4'
        6 * (1024 ** 3)
      when '4.3.2.1'
        2 * (1024 ** 3)
      end
    }
    Billing::Bandwidths.stub(:bytes, results) do
      usage = Billing::Bandwidths.gigabytes_for_project(@project_id, @from, @to)
      assert_equal 8, usage
    end
  end

  def test_usage_case_partial_period_one_address
    Billing::Ip.create! address: '1.2.3.4', project_id: @project_id,
                   ip_type: 'ip.floating', recorded_at: @from + 2.weeks,
                   ip_id: 'foobar'
    Billing::Bandwidths.stub(:bytes, 1 * (1024 ** 3), ['1.2.3.4', @from + 2.weeks, @to]) do
      usage = Billing::Bandwidths.gigabytes_for_project(@project_id, @from, @to)
      assert_equal 1, usage
    end
  end

  def test_usage_case_partial_released_address
    Billing::Ip.create! address: '1.2.3.4', project_id: @project_id,
               ip_type: 'ip.floating', recorded_at: @from,
               ip_id: 'foobar'
    Billing::Ip.create! address: '1.2.3.4', project_id: 'new_guy',
                       ip_type: 'ip.floating', recorded_at: @from + 2.weeks,
                       ip_id: 'foobar'
    results =  ->(_,from,to) {
      case @project_id
      when 'foo'
        assert_equal @from, from
        assert_equal (from + 2.weeks).to_i, to.to_i
        6 * (1024 ** 3)
      when 'new_guy'
        assert_equal (@from + 2.weeks).to_i, from.to_i
        assert_equal @to, to
        2 * (1024 ** 3)
      end
    }
    Billing::Bandwidths.stub(:bytes, results) do
      usage = Billing::Bandwidths.gigabytes_for_project(@project_id, @from, @to)
      assert_equal 6, usage
      @project_id = 'new_guy'
      usage = Billing::Bandwidths.gigabytes_for_project(@project_id, @from, @to)
      assert_equal 2, usage
    end
  end

  def test_usage_case_none
    usage = Billing::Bandwidths.gigabytes_for_project(@project_id, @from, @to)
    assert_equal 0, usage
  end

  def test_usage_case_none_future
    Billing::Ip.create! address: '1.2.3.4', project_id: @project_id,
                   ip_type: 'ip.floating', recorded_at: Time.now + 4.months,
                   ip_id: 'foobar'
    usage = Billing::Bandwidths.gigabytes_for_project(@project_id, @from, @to)
    assert_equal 0, usage
  end
end
