require 'spec_helper'

RSpec.shared_examples 'a device subscription focused interactor' do |platform|
  context 'when the provided bundle_identifier is unknown' do
    it 'fails the result with an error message' do
      result = described_class.call(bundle_identifier: 'com.some.id')

      expect(result).to_not be_success
      expect(result.message).to eq 'Unknown bundle_identifier: com.some.id'
    end
  end

  context 'when the provided bundle_identifier only registered with another platform' do
    it 'fails the result with an error message' do
      platform_trait = (platform.to_sym == :apns ? :gcm : :apns)
      create(:sns_application, platform_trait, bundle_identifier: 'come.some.id')
      result = described_class.call(bundle_identifier: 'com.some.id')

      expect(result).to_not be_success
      expect(result.message).to eq 'Unknown bundle_identifier: com.some.id'
    end
  end
end
