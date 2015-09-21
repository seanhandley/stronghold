Starburst.configuration do |config|
  config.current_user_method = "current_user"
  config.user_instance_methods  = ["cloud?"]
end