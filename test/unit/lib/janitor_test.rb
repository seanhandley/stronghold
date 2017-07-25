require 'test_helper'



class TestJanitor < CleanTest

  def setup
    @instance = Billing::Instance.create!({
      instance_id: 'ff90714a-6b5e-45e4-9253-c952b63bb3d6',
      name: 'foo',
    })
    @live_servers = [
      {'id' => 'ff90714a-6b5e-45e4-9253-c952b63bb3d6'}
    ]
    t = Time.now - 1.month
    Billing::Sync.create! completed_at: t,
                          started_at:   t,
                          period_from:  t,
                          period_to:    t
    Billing::Instance.redefine_method(:raw_billable_states) { [] }
  end

  def test_if_instance_still_exists_do_nothing
    LiveCloudResources.stub(:send, @live_servers, [:servers]) do
      Janitor.sweep(test_data)
    end
    assert_equal 1, Billing::Instance.all.count
  end

  def test_instance_has_zero_events_and_doesnt_exist_anymore
    LiveCloudResources.stub(:servers, []) do
      Janitor.sweep(test_data)
    end
    assert_equal 0, Billing::Instance.all.count
  end

  def test_instance_unchanged_if_dry_run
    LiveCloudResources.stub(:servers, []) do
      Janitor.sweep(test_data, dry_run: true)
    end
    assert_equal 1, Billing::Instance.all.count
  end

  def test_instance_with_events_gets_a_deleted_event_added
    t = Time.now - 2.weeks
    @instance.instance_states.create! recorded_at: t,
                                      state:       'building',
                                      event_name:  'compute.instance.create.start'
    @instance.instance_states.create! recorded_at: (t + 5.seconds),
                                      state:       'active',
                                      event_name:  'compute.instance.create.end'
    @instance.reindex_states

    @billable_seconds = @instance.total_billable_seconds

    LiveCloudResources.stub(:servers, []) do
      Janitor.sweep(test_data)
    end

    Timecop.freeze(Time.now + 1.year) do
      assert_equal @billable_seconds, @instance.reload.total_billable_seconds
    end

    assert_equal 3, @instance.instance_states.count  
  end

  def test_instance_with_billable_raw_events_stays
    t = Time.now - 2.weeks
    @instance.instance_states.create! recorded_at: t,
                                      state:       'building',
                                      event_name:  'compute.instance.create.start'
    @instance.reindex_states

    Billing::Instance.redefine_method(:raw_billable_states) { ['active'] }

    LiveCloudResources.stub(:servers, []) do
      Janitor.sweep(test_data)
    end

    assert_equal 1, Billing::Instance.all.count 
  end

  def test_instance_with_events_untouched_after_dry_run
    t = Time.now - 2.weeks
    @instance.instance_states.create! recorded_at: t,
                                      state:       'building',
                                      event_name:  'compute.instance.create.start'
    @instance.reindex_states

    LiveCloudResources.stub(:servers, []) do
      Janitor.sweep(test_data, dry_run: true)
    end

    assert_equal 1, @instance.instance_states.count
  end

  private

  def test_data
    {
      :missing_instances => {
        "ff90714a-6b5e-45e4-9253-c952b63bb3d6" => {
          :name       => "testing_stress_arctic_1",
          :project_id => "d24c8005301644589999103298c62048"
        }
      },
      :missing_volumes => {},
      :missing_images  => {},
      :new_instances   => {},
      :sane            => false
    }
  end
end
