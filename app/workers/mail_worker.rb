class MailWorker
  include Sidekiq::Worker

  def perform(mailer_action, *args)
    Mailer.send(mailer_action.to_sym, *args).deliver
  end
end