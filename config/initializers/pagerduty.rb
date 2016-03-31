require 'pagerduty'

PD_SETTINGS = YAML.load_file("#{Rails.root}/config/pagerduty.yml")[Rails.env]
PD_CLIENT = Pagerduty.new token: Rails.application.secrets.pagerduty_token,
                          subdomain: PD_SETTINGS['subdomain']

def pager_duty_loop
  thread = Thread.new do
    msg = []
    incident_key = nil
    loop do
      sleep 3
      puts "Waking up"
      PD_SETTINGS['monitored_services'].each do |name, info|
        begin
          msg << "#{name} is not running. Start with '#{info['start']}'" unless `#{info['status']}`.include?(info['test'])
        rescue StandardError => e
          puts e.message
        end
      end
      params = {'service_key' => PD_SETTINGS['service_key'],
          'description' => msg.join(". ")}
      params.merge!('incident_key' => incident_key) if incident_key
      if msg.any?
        incident = PD_CLIENT.trigger params
        incident_key = incident.incident_key
      else
        PD_CLIENT.resolve params.merge('description' => 'Services are running again')
        incident_key = nil
      end
      msg = []
    end
  end

  at_exit do
    Thread.kill(thread)
  end
end

pager_duty_loop