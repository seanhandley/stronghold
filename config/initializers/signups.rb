module Stronghold
  SIGNUPS_ENABLED=false
end

if Stronghold::SIGNUPS_ENABLED
  InformWaitListJob.perform_later
end