module InstanceHistory
  def initialize(params)
    super
    instance_states
  end

  def instance_states
    @is ||= model.instance_states.to_a
  end

  def fetch_states(from, to)
    states = instance_states.select{|is| (from..to).include? is.recorded_at}
    if states.any?
      # Sometimes states arrive out of order and the final state by timestamp
      # isn't actually the final state. This can make instances appear to be
      # active, even after they're deleted.
      if states.collect(&:state).include?('deleted')
        found_deleted = false
        return states.take_while do |state| 
          begin
            !found_deleted
          ensure
            found_deleted = true if state.state == 'deleted'
          end
        end
      end
    end
    states
  end

  def history(from, to)
    history = fetch_states(from, to).to_a
    history.unshift(history.first.previous_state) if history&.first&.previous_state
    history = history.map do |state|
      state.to_hash(from, to)
    end
    return history if history.count > 0
    latest_state = instance_states.select{|is| is.recorded_at < from}.last

    if latest_state && from >= latest_state.recorded_at
      return [latest_state.to_hash(from, to)] if latest_state&.billable?
    end
    []
  end

  def billable_history(from, to)
    history(from, to).select{|i| i[:billable]}
  end

  def billable_seconds(from, to)
    Hash[billable_history(from, to).group_by{|i| i[:flavor]}.map {|flavor, instances|
      [flavor, instances.sum{|i| i[:seconds]}]
    }]
  end

  def billable_hours(from, to)
    Hash[billable_seconds(from, to).map {|flavor, seconds|
      [flavor, (seconds / Billing::SECONDS_TO_HOURS).ceil]
    }]
  end

  def cost(from, to)
    cost_by_flavor(from, to).sum {|_,c| c}
  end

  def cost_by_flavor(from, to)
    Hash[billable_hours(from, to).map {|flavor, hours|
      begin
        product_id = Salesforce.find_instance_product(flavor, windows: Windows.billable?(self))['salesforce_id']
        price = Salesforce::Product.all[product_id][:price]
        [flavor, price * hours]
      rescue StandardError => e
        Honeybadger.notify(StandardError.new("No flavor: #{flavor}"))
        nil
      end
    }.compact]
  end
end
