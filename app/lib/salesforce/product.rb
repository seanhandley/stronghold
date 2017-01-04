module Salesforce
  class Product
    def self.all      
      @@product_map ||= Hash[Restforce.new.query("select id, name from product2").instance_variable_get(:@raw_page)['records'].map {|r|
        [r['Id'], {name: r['Name'], price: PriceBook.all[r['Id']]}]
      }]
    end
  end
end
