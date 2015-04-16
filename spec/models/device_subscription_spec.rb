require 'rails_helper'

describe DeviceSubscription do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:bundle_id) }
    it { is_expected.to validate_presence_of(:endpoint_arn) }
    it { is_expected.to validate_presence_of(:logged_in_user_id) }
    it { is_expected.to validate_presence_of(:platform) }
    it { is_expected.to validate_presence_of(:platform_device_identifier) }

    it { is_expected.to validate_inclusion_of(:platform).in_array(['APNS']) }

    context 'when the subscription is on APNS' do
      before { subject.platform = described_class::PLATFORM_APNS }

      it 'adds a validation error for the platform_device_identifier if it is not a Apple device token' do
        not_tokens = []
        not_tokens << '<12345678 12345678 12345678 12345678 12345678 12345678 12345678 12345678>' # example string returned by device
        not_tokens << '12345678 12345678 12345678 12345678 12345678 12345678 12345678 12345678' # example string returned by device sans brackets
        not_tokens << '12345678123456781234567812345678123456781234567812345678123456' # string that is too short

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

    it 'adds a validation error when the bundle_id is not formatted correctly' do
      not_ids = []
      not_ids << 'co.ello'
      not_ids << 'coelloello'
      not_ids << 'co-ello-ello'

      not_ids.each do |id|
        subject.bundle_id = id
        subject.valid? # run validations
        expect(subject.errors[:bundle_id]).to include('not a valid bundle id')
      end
    end

    it 'does not add a validation error when the bundle_id is formatted correctly' do
      subject.bundle_id = 'co.ello.ello'
      subject.valid? # run validations
      expect(subject.errors[:bundle_id]).to be_empty
    end
  end

  describe '#apns?' do
    it 'returns true when the platform is APNS' do
      subject.platform = described_class::PLATFORM_APNS

      expect(subject).to be_apns
    end

    it 'returns false when the platform is not APNS' do
      ['GCM', 'SMS', nil].each do |platform|
        subject.platform = platform

        expect(subject).to_not be_apns
      end
    end
  end

  describe '#creatable_on_sns?' do
    subject { build(:device_subscription, :apns) }

    it 'returns false if the subscription already has an endpoint arn' do
      expect(subject).to_not be_creatable_on_sns
    end

    it 'returns false if the subscription is invalid for any key other than the endpoint arn' do
      subject.endpoint_arn = nil
      subject.logged_in_user_id = nil
      expect(subject).to_not be_creatable_on_sns
    end

    it 'returns true if the subscription is valid other than the endpoint arn' do
      subject.endpoint_arn = nil
      expect(subject).to be_creatable_on_sns
    end
  end

end
