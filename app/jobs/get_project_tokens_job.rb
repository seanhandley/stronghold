class GetProjectTokensJob < ActiveJob::Base
  queue_as :default

  def perform(user, password)
    Terminal::OpenStackCommand.get_project_tokens(user, GIBBERISH_CIPHER.decrypt(password))
  end
end
