source 'https://rubygems.org'
ruby "2.5.9"

gem 'rails', '~> 6.1.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'pg'
gem 'puma', '~> 3.12'
gem 'rack-cors', require: 'rack/cors'
gem 'active_model_serializers', '~> 0.10.0'
gem 'httparty'
gem 'delayed_job_active_record'
gem 'daemons' # required by delayed_job

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'pry'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'guard'
  gem 'guard-minitest'
  gem 'minitest-rails'
  gem 'database_cleaner'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
