class UserDecorator < ApplicationDecorator
  def as_sirportly_data
    {
      reference: model.email,
      contact_methods: {
        email: [
          model.email
        ]
      },
      first_name: model.first_name,
      last_name: model.last_name,
      company: model.organization.name,
      timezone: model.organization.time_zone
    }
  end
end
