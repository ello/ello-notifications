RSpec.configure do |config|
  config.before(:each) do
    Aws.config[:stub_responses] = true
  end
end
