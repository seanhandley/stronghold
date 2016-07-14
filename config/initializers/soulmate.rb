SOULMATE_SEARCHABLE_MODELS = ["organization", "project", "user"]

require_relative '../../lib/soulmate_loader'

if Rails.env.development?
  begin
    Rails.application.reload_routes!
    SoulmateLoader.load_search_terms
  rescue StandardError => e
    puts "Couldn't load Soulmate entries: #{e.to_s}"
  end
end
