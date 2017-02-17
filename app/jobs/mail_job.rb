class MailJob < ApplicationJob
  queue_as :default

  def perform(mailer_action, *args)
    Time.use_zone('London') {
      Mailer.send(mailer_action.to_sym, *args).deliver_later_by_api
    }
  end
end