RSpec.configure do |config|
  config.before(:suite) do
    Aws.config[:stub_responses] = true
  end
end
