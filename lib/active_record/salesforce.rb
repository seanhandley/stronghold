module ActiveRecord
  class Base

    def self.syncs_with_salesforce

      define_method :salesforce_args do
        {
          Name: name, Type: 'Customer',
          Billingstreet: [billing_address1, billing_address2].join("\n").strip,
          Billingcity: billing_city, Billingpostalcode: billing_postcode,
          Billingcountry: Country.find_country_by_alpha2(billing_country), Phone: phone
        }
      end

      define_method :create_salesforce_object do
        update_column(:salesforce_id, Restforce.new.create('Account', salesforce_args)
        )
      end

      define_method :delete_salesforce_object do
        # Restforce.new.update('Account', {Status: 'Closed'}.merge(Id: salesforce_id))
      end

      define_method :update_salesforce_object do
        Restforce.new.update('Account', salesforce_args.dup.merge(Id: salesforce_id))
      end

      self.class_eval do
        unless Rails.env.test? || Rails.env.staging?
          after_create(:create_salesforce_object)
          after_update(:update_salesforce_object)
        end
      end
    end
  end
end
