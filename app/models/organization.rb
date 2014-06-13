class Organization < ActiveRecord::Base
  after_create :generate_reference

  validates :name, length: {minimum: 1}, allow_blank: false

  has_many :users
  has_many :roles

  def tickets
    OrganizationTickets.new(reference)
  end

  private

  def generate_reference
    return if reference
    ref = name.parameterize.gsub('-','').upcase.slice(0,8)
    count = 0
    until([Organization.find_by_reference(ref)].flatten.compact.empty?) do
      ref = (ref + (count += 1).to_s)
    end
    update_column(:reference, ref)
  end

end