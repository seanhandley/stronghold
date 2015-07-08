source 'https://rubygems.org'

gem 'rails', '4.2'
gem 'mysql2', '~> 0.3.18'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0',  group: :doc
gem 'bcrypt', '~> 3.1.7'
gem 'unicorn', '~> 4.8.3'
gem 'haml', '~> 4.0.5'
gem 'cancancan', '~> 1.9.2'
gem 'fog', '~> 1.31.0'
gem 'gravatar_image_tag', '~> 1.2.0'
gem 'js-routes', '~> 0.9.9'
gem 'sidekiq', '~> 3.3'
gem 'database_cleaner', '~> 0.8.0'
gem 'audited-activerecord', git: 'https://github.com/collectiveidea/audited.git', tag: 'v4.0.0.rc1'
gem 'verbs', '~> 2.1.4'
gem 'faraday', '~> 0.9.0'
gem 'redcarpet', '~> 3.1.2'
gem 'async-rails', '~> 0.9.0'
gem 'newrelic_rpm', '~> 3.9.9'
gem 'honeybadger', '~> 1.7.0'
gem 'hipchat', '~> 1.3.0'
gem 'sirportly', '~> 1.3.6'
gem 'kaminari', '~> 0.16.1'
gem 'bootstrap-kaminari-views', '~> 0.0.5'
gem 'dalli', '~> 2.7.2'
gem 'clockwork', '~> 1.1.0'
gem 'aws-s3', git: 'https://github.com/datacentred/aws-s3.git'
gem 'rails_admin', '~> 0.6.7'
gem 'sinatra', '>= 1.3.0'
gem 'responders', '~> 2.0'
gem 'restforce', '~> 1.5.1'
gem 'starburst', '~> 1.0.3'
gem 'country_select'
gem 'countries'
gem "recaptcha", :require => "recaptcha/rails"
gem 'tel_to_helper'
gem 'rest-client', '~> 1.6'
gem 'geo_ip', '~> 0.5.0'
gem 'world-flags', '~> 0.6'
gem 'nokogiri'
gem 'premailer-rails'
gem "minitest-rails"
gem "slack-notifier"
gem "maxmind"
gem "deep_merge"
gem 'stripe-rails'

group :test, :acceptance do
  gem 'faker'
  gem 'machinist'
  gem "minitest-rails-capybara"
  gem 'poltergeist'
  gem 'simplecov'
  gem 'timecop'
  gem 'launchy'
end

group :test do
  gem 'webmock'
  gem 'vcr'
end

# Assets gems
gem "select2-rails", '~> 3.5.9.1'
gem 'font-awesome-sass', '~> 4.2.0'
gem 'bootstrap-sass', '~> 3.1.1'
gem 'jquery-rails', '~> 4.0.3'
gem 'jquery-ui-rails'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'therubyracer', '~> 0.12.1', platforms: :ruby
gem 'momentjs-rails', '~> 2.8.3'

source 'https://rails-assets.org' do
  gem 'rails-assets-angular', '~> 1.2.24'
  gem 'rails-assets-angular-resource', '~> 1.2.24'
  gem 'rails-assets-angular-bootstrap', '~> 0.11.0'
  gem 'rails-assets-angular-sanitize', '~> 1.2.24'
  gem 'rails-assets-angular-gravatar', '~> 0.2.1'
  gem 'rails-assets-angular-animate', '~> 1.2.24'
  gem 'rails-assets-angular-md5', '~> 0.1.7'
  gem 'rails-assets-angular-infinite-scroll', '~> 0.0.1'
  gem 'rails-assets-chained', '~> 1.0.0'
  gem 'rails-assets-bootstrap-select'
  gem 'rails-assets-hideShowPassword'
  gem 'rails-assets-normalize-css'
end

group :development do
  gem 'i18n_yaml_sorter', '~> 0.2.0'
  gem 'capistrano',  '~> 3.1'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'net-ssh', '~> 2.8.0'
  gem 'spring', '~> 1.1.3'
  gem 'web-console', '~> 2.0' 
end

group :production do 
  gem 'unicorn-worker-killer', '~> 0.4.2'
end
