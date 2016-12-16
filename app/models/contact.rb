class Contact < ActiveRecord::Base
  has_and_belongs_to_many :users
  belongs_to :organization

  def billing_type
    if current_organization.contacts.present?
      current_organization.contacts
    else
      nil
    end
  end

  def technical_type
    if current_organization.contacts.present?
      'none'
    else
      nil
    end
  end
end
