module Salesforce
  class PriceBook
    def self.all
      @@pricebook_map ||= Hash[Restforce.new.query("select product2id, unitprice from pricebookentry").instance_variable_get(:@raw_page)['records'].map{|r| [r['Product2Id'], r['UnitPrice']]}]
    end
  end
end
