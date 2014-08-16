# Classes that include this module can be used
# by the Audited gem as "Auditable" models
module ActiveRecord
  module FakeModel

    def [](key); self.send(key); end
    def destroyed?; false ; end
    def new_record?; false ; end

    def self.primary_key; :id; end

    def self.inherited(subclass)
      subclass.define_singleton_method(:base_class) { subclass }
    end
    
  end
end