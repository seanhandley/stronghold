class Organization < ActiveRecord::Base

  has_many :users
  has_many :roles

  def tickets
    OrganizationTickets.new(reference)
  end

end