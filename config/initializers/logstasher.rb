if LogStasher.enabled
  LogStasher.add_custom_fields do |fields|
    fields[:user] = current_user && current_user.email
  end
end