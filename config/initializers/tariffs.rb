TARIFFS = {}
for tariff in Dir.glob("#{Rails.root}/config/tariffs/*")
  key = File.basename(tariff, ".yml")
  TARIFFS[key] = YAML.load_file(tariff)
end