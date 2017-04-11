class UserDecorator < ApplicationDecorator
  def as_sirportly_data
    {
      reference: model.id,
      contact_methods: {
        email: [
          model.email
        ]
      },
      first_name: model.first_name,
      last_name: model.last_name,
      company: model.primary_organization.reference,
      timezone: model.primary_organization.time_zone
    }
  end
end
