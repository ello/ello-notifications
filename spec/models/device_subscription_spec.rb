require 'rails_helper'

describe DeviceSubscription do

  describe 'default values' do
    it 'defaults to enabled' do
      expect(subject).to be_enabled
    end

    it 'does not override a false value' do
      expect(described_class.new({enabled: false})).to_not be_enabled
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:logged_in_user_id) }
    it { is_expected.to validate_presence_of(:platform_device_identifier) }

    context 'when the subscription is on APNS' do
      subject { build(:device_subscription, :apns) }

      it 'adds a validation error for the platform_device_identifier if it is not a Apple device token' do
        not_tokens = []
        not_tokens << '<1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a>' # example string returned by device
        not_tokens << '1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a 1a3a5a7a' # example string returned by device sans brackets
        not_tokens << '1z3z5z7z1z3z5z7z1z3z5z7z1z3z5z7z1z3z5z7z1z3z5z7z1z3z5z7z1z3z5z7z' # string that is not valid hexadecimal
        not_tokens << '1a3a5a7a1a3a5a7a1a3a5a7a1a3a5a7a1a3a5a7a1a3a5a7a1a3a5a7a1a3a5a' # hexadecimal string that is too short

        not_tokens.each do |token|
          subject.platform_device_identifier = token
          subject.valid? # run validations
          expect(subject.errors[:platform_device_identifier]).to include('not a valid device token')
        end
      end

      it 'does not add a validation error for the platform_device_identifier when it is an Apple device token' do
        subject.platform_device_identifier = 'a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4'
        subject.valid? # run validations
        expect(subject.errors[:platform_device_identifier]).to be_empty
      end
    end
  end

  describe '#apns?' do
    it 'returns true when the linked application platform is APNS' do
      subject.sns_application = build(:sns_application, :apns)

      expect(subject).to be_apns
    end

    it 'returns false when the linked application platform is not APNS' do
      ['GCM', 'SMS', nil].each do |platform|
        subject.sns_application = build(:sns_application, platform: platform)

        expect(subject).to_not be_apns
      end
    end
  end

  describe '#platform' do
    subject { build_stubbed(:device_subscription, :apns) }
    it 'returns the platform identifier for the linked application' do
      expect(subject.platform).to eq(SnsApplication::PLATFORM_APNS)
    end
  end

  describe '#creatable_on_sns?' do
    subject { build(:device_subscription, :apns) }

    it 'returns false and adds an error message if the subscription already has an endpoint arn' do
      expect(subject).to_not be_creatable_on_sns
      expect(subject.errors[:endpoint_arn]).to include 'SNS endpoint has already been created'
    end

    it 'returns false if the subscription is invalid' do
      subject.endpoint_arn = nil
      subject.logged_in_user_id = nil
      expect(subject).to_not be_creatable_on_sns
    end

    it 'returns true if the subscription is valid' do
      subject.endpoint_arn = nil
      expect(subject).to be_creatable_on_sns
    end
  end

  describe '#disabled?' do
    it 'returns true when enabled is false' do
      expect(described_class.new(enabled: false)).to be_disabled
    end

    it 'returns false when enabled is true' do
      expect(described_class.new(enabled: true)).to_not be_disabled
    end
  end

end
