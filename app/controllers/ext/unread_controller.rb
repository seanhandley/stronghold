module Ext
  class UnreadController < ActionController::Base
    def create
      Rails.logger.info '*' * 10
      Rails.logger.info params.inspect
      Rails.logger.info '*' * 10
    end
  end
end
