module ActiveRecord
  class Base

    def self.syncs_with_salesforce

      define_method :salesforce_args do
        {
          Name: name, Type: 'Customer',
          Billingstreet: [billing_address1, billing_address2].join("\n").strip,
          Billingcity: billing_city, Billingpostalcode: billing_postcode,
          Billingcountry: billing_country, Phone: phone
        }
      end

      define_method :create_salesforce_object do
        update_column(:salesforce_id, Restforce.new.create('Account', salesforce_args)
        )
      end

      define_method :delete_salesforce_object do
        # Restforce.new.update('Account', {Status: 'Closed'}.merge(Id: salesforce_id))
      end

      def update_salesforce_object
        Restforce.new.update('Account', salesforce_args.dup.merge(Id: salesforce_id))
      end

      self.class_eval do
        unless Rails.env.test?
          after_create do
            create_salesforce_object
          end
          before_destroy do
            delete_salesforce_object
          end
          after_update do
            update_salesforce_object
          end
        end
      end
    end
  end
end
