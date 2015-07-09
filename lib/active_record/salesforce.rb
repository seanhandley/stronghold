module ActiveRecord
  class Base

    def self.syncs_with_salesforce

      define_method :salesforce_args do
        {
          Name: name, Type: 'Customer',
          Billingstreet: [billing_address1, billing_address2].join("\n").strip,
          Billingcity: billing_city, Billingpostalcode: billing_postcode,
          Billingcountry: Country.find_country_by_alpha2(billing_country), Phone: phone,
          c2g__CODAReportingCode__c: reporting_code,
          c2g__CODABillingMethod__c: 'Self-Service',
          Usage_Value__c: usage_value,
          c2g__CODADescription1__c: payment_card_type,
          c2g__CODABaseDate1__c: "Invoice Date"
          c2g__CODADaysOffset1__c: 0
        }
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

      self.class_eval do
        unless Rails.env.test? || Rails.env.acceptance? || Rails.env.staging?
          after_commit(:create_salesforce_object, on: :create)
          after_commit(:update_salesforce_object, on: :update)
        end
      end
    end
  end
end

class CreateSalesforceObjectJob < ActiveJob::Base
  queue_as :default

  def perform(o)
    o.update_column(:salesforce_id, Restforce.new.create('Account', o.salesforce_args))
    Mailer.notify_staff_of_signup(o).deliver_later
  end
end

class UpdateSalesforceObjectJob < ActiveJob::Base
  queue_as :default

  def perform(o)
    Restforce.new.update('Account', o.salesforce_args.dup.merge(Id: o.salesforce_id))
  end
end