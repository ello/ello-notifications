# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    Aws.config[:stub_responses] = true
  end
end
