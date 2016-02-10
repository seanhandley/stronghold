module DaemonControlHelper
  def restart_sidekiq
    (stop_sidekiq; start_sidekiq) if Rails.env.production?
  end

  def restart_clockwork
    (stop_clockwork; start_clockwork) if Rails.env.production?
  end

  def stop_sidekiq
    `sudo stop sidekiq_stronghold`
  end

  def start_sidekiq
    `sudo start sidekiq_stronghold`
  end

  def stop_clockwork
    `sudo stop clockwork_stronghold`
  end

  def start_clockwork
    `sudo start clockwork_stronghold`
  end

  def restart_message
    "Restart command sent."
  end
end