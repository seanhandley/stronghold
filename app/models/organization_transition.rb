class OrganizationTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :organization, inverse_of: :transitions
end
