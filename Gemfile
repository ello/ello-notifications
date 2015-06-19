source 'https://rubygems.org'
ruby '2.2.2'

gem 'rails', '4.1.7.1'

# priority development gems that should be loaded before anything else
group :development, :test do
  gem 'dotenv-rails', require: 'dotenv/rails-now'
  gem 'pry-rails'
end

gem 'rails-api'
gem 'puma', '2.11.3'

gem 'pg'
gem 'interactor', '~> 3.0'
gem 'aws-sdk', '~> 2'
gem 'ello_protobufs', git: 'https://d2875f16aaedb1581039f5da38bf53250aadf4e2@github.com/ello/ello_protobufs.git'

gem 'newrelic_rpm', '~> 3.12.0'
gem 'librato-rails', '~> 0.11.1'
gem 'honeybadger', '~> 2.1.0'

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
  gem 'rspec-rails', '~> 3.0'
end

group :test do
  gem 'shoulda-matchers'
end
