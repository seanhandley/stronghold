class FraudCheckJob < ActiveJob::Base
  queue_as :default

  def perform(args)
    results = Fraudrecord.query(args)
    threshold = 2
    if [results[:value], results[:count], results[:reliability]].any? {|r| r >= threshold}
      Mailer.fraud_check_alert(args, results[:report]).deliver_now
    end
  end
end
