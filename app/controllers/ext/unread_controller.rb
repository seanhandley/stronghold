module Ext
  class UnreadController < ActionController::Base
    def create
      Rails.logger.info '*' * 10
      ticket       = params.to_h['ticket']
      update       = params.to_h['update']
      organization = Organization.find_by reference: ticket['reference'].split[0]
      from_user    = User.find_by email: update['from_address']
      Rails.logger.info "#{organization.name}: #{from_user.name}"
      Rails.logger.info '*' * 10
    end
  end
end
