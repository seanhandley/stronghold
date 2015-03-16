class SalesforceController < ApplicationController
  def update
    Rails.logger.debug "Salesforce OAuth response: #{params.inspect}"
    head :no_content
  end
end