module SidekiqControlHelper
  def restart_sidekiq
    if Rails.env.production?
      `sudo stop sidekiq_stronghold`
      `sudo start sidekiq_stronghold`
    end
  end

  def restart_message
    "Restart command sent."
  end
end