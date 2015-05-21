module BasicAuthHelpers
  extend ActiveSupport::Concern

  included do
    def basic_auth_env
      { 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("#{ENV['BASIC_AUTH_USER']}:#{ENV['BASIC_AUTH_PASSWORD']}") }
    end
  end
end

RSpec.configure do |config|
  config.include BasicAuthHelpers, type: :request
end
