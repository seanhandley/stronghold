class ApplicationRecord < ActiveRecord::Base
  extend ActiveRecord::Salesforce
  extend ActiveRecord::Openstack
  extend ActiveRecord::Ceph

  self.abstract_class = true
end