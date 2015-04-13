module ActiveRecord
  class Base

    def self.syncs_with_salesforce
      define_method :create_salesforce_object do
        update_column(:salesforce_id, Restforce.new.create('Account', Name: name))
      end

      define_method :delete_salesforce_object do
        Restforce.new.destroy('Account', salesforce_id)
      end

      define_method :update_salesforce_object do
        Restforce.new.update('Account', Id: salesforce_id, Name: name)
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
