module Stronghold
  SIGNUPS_ENABLED=true
end

if Stronghold::SIGNUPS_ENABLED
  InformWaitListJob.perform_later
end