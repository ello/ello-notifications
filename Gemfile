# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.6.7'

gem 'rails', '~> 4.2.5'

# priority development gems that should be loaded before anything else
group :development, :test do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'pry-rails'
end

gem 'puma', '~> 4.3.3'
gem 'rails-api'

gem 'aws-sdk', '~> 2.2'
gem 'ello_protobufs', github: 'ello/ello_protobufs', ref: '73bfe15'
gem 'interactor', '~> 3.0'
gem 'kinesis-stream-reader', require: 'stream_reader', github: 'ello/kinesis-stream-reader'
gem 'pg'
gem 'retries'

gem 'honeybadger', '~> 2.1'
gem 'librato-rails', '~> 1.4.2'
gem 'newrelic_rpm', '~> 3.18.0'
gem 'sucker_punch', '~> 2.0'

group :production do
  gem 'rails_12factor'
end

# gem 'spring', :group => :development

group :development do
  gem 'rubocop'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development, :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'json_spec'
  gem 'rspec-rails', '~> 3.6'
end

group :test do
  gem 'shoulda-matchers'
end
