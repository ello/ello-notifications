source 'https://rubygems.org'


gem 'rails', '4.1.7.1'
gem 'rails-api'

gem 'pg'
gem 'interactor', '~> 3.0'
gem 'aws-sdk', '~> 2'
gem 'ello_protobufs', git: 'https://d2875f16aaedb1581039f5da38bf53250aadf4e2@github.com/ello/ello_protobufs.git'

# Use unicorn as the app server
# gem 'unicorn'

# gem 'spring', :group => :development

group :development, :test do
  gem 'database_cleaner'
  gem 'dotenv-rails'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'faker'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'json_spec'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 3.0'
end

group :test do
  gem 'shoulda-matchers'
end
