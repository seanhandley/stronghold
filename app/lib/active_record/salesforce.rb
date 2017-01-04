module ActiveRecord
  module Salesforce
    def syncs_with_salesforce(params)

      define_method :salesforce_class do
        params[:as]
      end

      define_method :create_salesforce_object do
        CreateSalesforceObjectJob.perform_later(self) unless self.salesforce_id.present?
      end

      define_method :delete_salesforce_object do
        # Restforce.new.update('Account', {Status: 'Closed'}.merge(Id: salesforce_id))
      end

      define_method :update_salesforce_object do
        UpdateSalesforceObjectJob.perform_later(self) if self.salesforce_id.present?
      end

      define_method :salesforce_object do
        Restforce.new.find(salesforce_class, salesforce_id)
      end

      self.class_eval do
        unless Rails.env.test? || Rails.env.acceptance?
          after_commit(:create_salesforce_object, on: :create) if params[:actions].include? :create
          after_commit(:update_salesforce_object, on: :update) if params[:actions].include? :update
        end
      end
    end
  end
end

class CreateSalesforceObjectJob < ApplicationJob
  queue_as :default

  def perform(o)
    id = Restforce.new.create!(o.salesforce_class, o.salesforce_args)
    o.update_column(:salesforce_id, id)
    Mailer.notify_staff_of_signup(o).deliver_later if o.salesforce_class == 'Account'
  end
end

class UpdateSalesforceObjectJob < ApplicationJob
  queue_as :default

  def perform(o)
    Restforce.new.update!(o.salesforce_class, o.salesforce_args.dup.merge(Id: o.salesforce_id))
  end
end