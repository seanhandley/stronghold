class RevokeProjectTokensJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    Terminal::OpenStackCommand.revoke_project_tokens(user)
  end
end
