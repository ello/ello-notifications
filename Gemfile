source 'https://rubygems.org'
ruby '2.3.1'

gem 'rails', '~> 4.2.5'

# priority development gems that should be loaded before anything else
group :development, :test do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'pry-rails'
end

gem 'rails-api'
gem 'puma', '~> 3.4.0'

gem 'pg'
gem 'interactor', '~> 3.0'
gem 'aws-sdk', '~> 2.2'
gem 'ello_protobufs', github: 'ello/ello_protobufs', ref: '03a35ae'
gem 'kinesis-stream-reader', require: 'stream_reader', github: 'ello/kinesis-stream-reader'
gem 'retries'

gem 'newrelic_rpm', '~> 3.12.0'
gem 'librato-rails', '~> 0.11.1'
gem 'honeybadger', '~> 2.1'
gem 'sucker_punch', '~> 2.0'

group :production do
  gem 'rails_12factor'
end

# gem 'spring', :group => :development

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
