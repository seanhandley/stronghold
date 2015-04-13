module ActiveRecord
  class Base

    def self.syncs_with_salesforce
      define_method :salesforce_args do
        {
          Name: name, Type: 'Customer',
          Billing_Street: [billing_address1, billing_address2].join(', '),
          Billing_City: billing_city, Billing_ZIP: billing_postcode,
          Billing_Country: billing_country, Phone: phone
        }
      end

      define_method :create_salesforce_object do
        update_column(:salesforce_id, Restforce.new.create('Account', salesforce_args)
        )
      end

      define_method :delete_salesforce_object do
        Restforce.new.destroy('Account', salesforce_id)
      end

      define_method :update_salesforce_object do
        Restforce.new.update('Account', salesforce_args.dup.merge(Id: salesforce_id))
      end

      self.class_eval do
        unless Rails.env.test?
          after_create(:create_salesforce_object)
          before_destroy(:delete_salesforce_object)
          after_update(:update_salesforce_object)
        end
      end
    end

  end
end
