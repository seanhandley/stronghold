class Organization < ActiveRecord::Base

  has_many :users

  def tickets
    OrganizationTickets.new(reference)
  end

end