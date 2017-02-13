require_relative "./stronghold_queue"

ClockworkWeb.redis = Redis.new(StrongholdQueue.settings)