class MailWorker
  include Sidekiq::Worker

  def perform(mailer_action, *args)
    Time.use_zone('London') {
      Mailer.send(mailer_action.to_sym, *args).deliver
    }
  end
end