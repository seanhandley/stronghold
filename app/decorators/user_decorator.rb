class UserDecorator < ApplicationDecorator
  def as_sirportly_data
    {
      reference: "stronghold_#{model.id}",
      contact_methods: {
        email: [
          model.email
        ]
      },
      first_name: model.first_name,
      last_name: model.last_name,
      company: model.organization.reference,
      timezone: model.organization.time_zone
    }
  end
end
