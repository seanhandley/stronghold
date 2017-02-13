source 'https://rubygems.org'

gem 'rails', '5.0.1'
gem 'mysql2', '~> 0.3'
gem 'sdoc', '~> 0.4.0',  group: :doc
gem 'bcrypt', '~> 3.1'
gem 'unicorn', '~> 5.0'
gem 'haml', '~> 4.0'
gem 'cancancan', '~> 1.15'
gem 'fog-openstack', '~> 0.1'
gem 'gravatar_image_tag', '~> 1.2.0'
gem 'js-routes', '~> 1.2'
gem 'sidekiq', '~> 4.0'
gem 'database_cleaner', '~> 1.5'
gem "audited", "~> 4.3"
gem "rails-observers", git: 'https://github.com/rails/rails-observers'
gem 'verbs', '~> 2.1.4'
gem 'faraday', '~> 0.9'
gem 'redcarpet', '~> 3.3'
gem 'async-rails', '~> 1.5'
gem 'honeybadger', '~> 2.3'
gem 'sirportly', '~> 1.3'
gem 'kaminari', '~> 0.16'
gem 'bootstrap-kaminari-views', '~> 0.0.5'
gem 'dalli', '~> 2.7'
gem 'clockwork', '~> 1.2'
gem 'clockwork_web', '~> 0.0.5'
gem 'aws-s3', git: 'https://github.com/datacentred/aws-s3.git'
gem 'sinatra', git: 'https://github.com/sinatra/sinatra'
gem 'responders', '~> 2.0'
gem 'restforce', '~> 2.1'
gem 'starburst', '~> 1.0'
gem 'country_select', '~> 2.2'
gem 'countries'
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
gem 'minitest-ci', :git => 'git@github.com:circleci/minitest-ci.git'
gem "useragent"
gem 'rack-contrib', :git => 'https://github.com/datacentred/rack-contrib', ref: '8d23be046955b7f7a8448ca54443bbf645e66596'
gem 'soulmate', :require => 'soulmate/server'
gem 'soulmatejs-rails'
gem 'redis-namespace'
gem 'statesman', '~> 2.0'
gem 'parallel'
gem 'docker-api', '~> 1.31'
gem 'gibberish', '~> 2.1'
gem 'paranoia', '~> 2.2'
gem 'harbour', git: 'git@github.com:datacentred/harbour.git', branch: 'master'

group :test, :acceptance do
  gem 'faker'
  gem 'machinist'
  gem "minitest-rails"
  gem "minitest-rails-capybara"
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'simplecov'
  gem 'timecop'
  gem 'launchy'
end

group :test do
  gem 'webmock'
  gem 'vcr', '2.9.3'
end

# Assets gems
gem "select2-rails", '~> 3.5.9.1'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'sprockets', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 2.7'
gem 'coffee-rails', '~> 4.1'
gem 'therubyracer', '~> 0.12.2', platforms: :ruby
gem 'momentjs-rails', '~> 2.8.3'
gem 'font-awesome-sass', '~> 4.5'


source 'https://rails-assets.org' do
  gem 'rails-assets-angular', '~> 1.4'
  gem 'rails-assets-angular-resource', '~> 1.2'
  gem 'rails-assets-angular-bootstrap', '~> 0.11'
  gem 'rails-assets-angular-sanitize', '~> 1.2'
  gem 'rails-assets-angular-gravatar', '~> 0.2'
  gem 'rails-assets-angular-animate', '~> 1.2'
  gem 'rails-assets-angular-md5', '~> 0.1'
  gem 'rails-assets-chained', '~> 1.0'
  gem 'rails-assets-bootstrap-select', '~> 1.7'
  gem 'rails-assets-hideShowPassword', '~> 2.0'
  gem 'rails-assets-normalize-css', '~> 3.0'
  gem 'rails-assets-clipboard', '~> 1.5'
  gem 'rails-assets-bootstrap-toggle'
  gem 'rails-assets-highcharts'
  gem 'rails-assets-jquery.terminal', '~> 0.10'
  gem 'rails-assets-angular-inview', '~> 2.2'
end

group :development do
  gem 'puma'
  gem 'i18n_yaml_sorter', '~> 0.2.0'
  gem 'capistrano',  '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'net-ssh', '~> 2.8.0'
  gem 'spring', '~> 1.1.3'
  gem 'web-console', '~> 3.0'
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

group :production, :staging do
  gem 'newrelic_rpm', '~> 3.9'
  gem 'unicorn-worker-killer', '~> 0.4.4'
  gem 'rack-attack'
end
