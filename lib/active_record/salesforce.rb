module ActiveRecord
  class Base

    def self.syncs_with_salesforce
      self.class_eval do
        unless Rails.env.test?
          after_create do
            run_salesforce_job -> { Salesforce.new(self).create_salesforce_object }
          end
          before_destroy do
            run_salesforce_job -> { Salesforce.new(self).delete_salesforce_object }
          end
          after_update do
            run_salesforce_job -> { Salesforce.new(self).update_salesforce_object }
          end
        end
      end
    end

    private

    def self.run_salesforce_job(lambda)
      SalesforceSyncJob.perform_later(lambda)
    end
      
  end

  class Salesforce

    def initialize(organization)
      @o = organization
    end

    def salesforce_args
      {
        Name: name, Type: 'Customer',
        Billing_Street: [@o.billing_address1, @o.billing_address2].join(', '),
        Billing_City: @o.billing_city, Billing_ZIP: @o.billing_postcode,
        Billing_Country: @o.billing_country, Phone: @o.phone
      }
    end

    def create_salesforce_object
      @o.update_column(:salesforce_id, Restforce.new.create('Account', salesforce_args)
      )
    end

    def delete_salesforce_object
      Restforce.new.destroy('Account', @o.salesforce_id)
    end

    def update_salesforce_object
      Restforce.new.update('Account', salesforce_args.dup.merge(Id: @o.salesforce_id))
    end
  end
end
