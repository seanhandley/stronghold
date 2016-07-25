class OrganizationTransition < ActiveRecord::Base
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :organization, inverse_of: :transitions

  after_save -> { organization.update_column(:state, to_state) }, on: :create
end
