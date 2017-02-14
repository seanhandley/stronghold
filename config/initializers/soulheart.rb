require_relative "./stronghold_queue"

Soulheart.redis = Redis.new(StrongholdQueue.settings)
