source 'https://rubygems.org'

gem 'rails', '~> 4.2.5'
gem 'mysql2', '~> 0.3'
gem 'sdoc', '~> 0.4.0',  group: :doc
gem 'bcrypt', '~> 3.1'
gem 'unicorn', '~> 4.8'
gem 'sinatra', '~> 1.4'
gem 'responders', '~> 2.0'
gem 'haml', '~> 4.0'
gem 'cancancan', '~> 1.9'
gem 'fog-openstack', '~> 0.1'
gem 'gravatar_image_tag', '~> 1.2.0'
gem 'js-routes', '~> 0.9.9'
gem 'sidekiq', '~> 4.0'
gem 'audited-activerecord', git: 'https://github.com/collectiveidea/audited.git', tag: 'v4.0.0.rc1'
gem 'verbs', '~> 2.1.4'
gem 'faraday', '~> 0.9'
gem 'redcarpet', '~> 3.3'
gem 'async-rails', '~> 0.9'
gem 'honeybadger', '~> 1.7'
gem 'sirportly', '~> 1.3'
gem 'kaminari', '~> 0.16'
gem 'bootstrap-kaminari-views', '~> 0.0.5'
gem 'dalli', '~> 2.7'
gem 'clockwork', '~> 1.2'
gem 'clockwork_web', '~> 0.0.5'
gem 'aws-s3', git: 'https://github.com/datacentred/aws-s3.git'
gem 'restforce', '~> 2.1'
gem 'starburst', '~> 1.0'
gem 'country_select', '~> 2.2'
gem 'countries', '~> 0.11'
gem "recaptcha", :require => "recaptcha/rails"
gem 'tel_to_helper'
gem 'rest-client', '~> 1.8'
gem 'geo_ip', '~> 0.6'
gem 'world-flags', '~> 0.6'
gem 'nokogiri', '~> 1.6'
gem 'premailer-rails', '~> 1.9'
gem "slack-notifier", '~> 1.2'
gem "maxmind", '~> 0.4'
gem "deep_merge", '~> 1.0'
gem 'stripe-rails', '~> 0.3'
gem 'deliverhq', '~> 0.0.1'
gem 'holidays', '~> 2.2'
gem "paranoia", "~> 2.0"
gem 'minitest-ci', :git => 'git@github.com:circleci/minitest-ci.git'
gem "useragent"
gem 'rack-contrib'
gem 'soulmate', :require => 'soulmate/server'
gem 'soulmatejs-rails'
gem 'redis-namespace'
gem 'statesman', '~> 2.0'
gem 'parallel'
gem 'docker-api', '~> 1.31'
gem 'gibberish', '~> 2.1'
gem 'sidekiq-unique-jobs', '~> 4.0'

group :test, :acceptance do
  gem 'faker'
  gem 'machinist'
  gem "minitest-rails"
  gem "minitest-rails-capybara"
  gem 'poltergeist'
  gem 'simplecov'
  gem 'timecop'
  gem 'launchy'
  gem 'database_cleaner', '~> 0.8.0'
end

group :test do
  gem 'webmock'
  gem 'vcr'
end

# Assets gems
gem "select2-rails", '~> 3.5.9.1'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'jquery-rails', '~> 4.0.3'
gem 'jquery-ui-rails'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 2.7'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', '~> 0.5', platforms: :ruby
gem 'momentjs-rails', '~> 2.8.3'
gem 'font-awesome-sass', '~> 4.5'


source 'https://rails-assets.org' do
  gem 'rails-assets-angular', '~> 1.2.24'
  gem 'rails-assets-angular-resource', '~> 1.2.24'
  gem 'rails-assets-angular-bootstrap', '~> 0.11.0'
  gem 'rails-assets-angular-sanitize', '~> 1.2.24'
  gem 'rails-assets-angular-gravatar', '~> 0.2.1'
  gem 'rails-assets-angular-animate', '~> 1.2.24'
  gem 'rails-assets-angular-md5', '~> 0.1.7'
  gem 'rails-assets-chained', '~> 1.0.0'
  gem 'rails-assets-bootstrap-select', '~> 1.7'
  gem 'rails-assets-hideShowPassword', '~> 2.0'
  gem 'rails-assets-normalize-css', '~> 3.0'
  gem 'rails-assets-clipboard', '~> 1.5'
  gem 'rails-assets-bootstrap-toggle'
  gem 'rails-assets-highcharts'
  gem 'rails-assets-jquery.terminal', '~> 0.10'
end

group :development do
  gem 'i18n_yaml_sorter', '~> 0.2.0'
  gem 'capistrano',  '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'net-ssh', '~> 2.8.0'
  gem 'spring', '~> 1.1.3'
  gem 'web-console', '~> 2.1'
end

group :development, :test do
  gem 'traceroute'
  gem 'brakeman', :require => false
  gem 'rack-mini-profiler', :require => false
  gem 'bullet'
  gem 'rubycritic'
  gem 'bundler-audit'
  gem 'rspec_junit_formatter', '0.2.2'
end

group :production do
  gem 'unicorn-worker-killer', '~> 0.4.2'
  gem 'rack-attack'
end

group :production, :staging do
  gem 'newrelic_rpm', '~> 3.9'
end
