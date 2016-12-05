class UserContact < ActiveRecord::Base
  audited :associated_with => :contact

  self.table_name = 'users_contacts'

  belongs_to :contact
  belongs_to :user
end
