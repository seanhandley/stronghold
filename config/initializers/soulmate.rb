SOULMATE_SEARCHABLE_MODELS = ["organization"]

unless Rails.env.production?
  Rails.application.reload_routes!
  SoulmateJob.perform_now
end
