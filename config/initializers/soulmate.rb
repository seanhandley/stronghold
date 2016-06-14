SOULMATE_SEARCHABLE_MODELS = ["organization", "reporting_code"]

if Rails.env.development?
  begin
    Rails.application.reload_routes!
    SoulmateJob.perform_now
  rescue StandardError => e
    puts "Couldn't load Soulmate entries: #{e.to_s}"
  end
end
