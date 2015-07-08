require 'rails_helper'

describe CreateDeviceSubscription do
  let(:request) do
    ElloProtobufs::NotificationService::CreateDeviceSubscriptionRequest.new({
      platform: ElloProtobufs::NotificationPlatform::APNS,
      platform_device_identifier: '12345',
      bundle_identifier: 'co.ello.ElloDev',
      logged_in_user_id: 1,
      marketing_version: '6.6.6',
      build_version: '1234567'
    })
  end

  context 'when the device subscription is for APNS' do
    it 'dispatches to the appropriate interactor' do
      mock_result = double('Result', success?: true, failure?: false)
      expect(APNS::CreateSubscription).to receive(:call).with({
        platform_device_identifier: request.platform_device_identifier,
        bundle_identifier: request.bundle_identifier,
        logged_in_user_id: request.logged_in_user_id,
        marketing_version: request.marketing_version,
        build_version: request.build_version
      }).and_return(mock_result)

      result = described_class.call(request: request)

      expect(result).to be_success
    end

    context 'when the dispatched interactor fails' do
      it 'bubbles up the failure with the appropriate reason' do
        failure_reason = ElloProtobufs::NotificationService::ServiceFailureReason::UNSPECIFIED_REASON
        message = 'some message'
        mock_result = build_failed_context(failure_reason: failure_reason, message: message)
        expect(APNS::CreateSubscription).to receive(:call).and_return(mock_result)

        result = described_class.call(request: request)

        expect(result).to_not be_success
        expect(result.message).to eq mock_result.message
      end
    end
  end

  context 'when the device subscription is for an unknown platform' do
    before { request.platform = ElloProtobufs::NotificationPlatform::UNSPECIFIED_PLATFORM }

    it 'fails the context' do
      expected_reason = ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_NOTIFICATION_PLATFORM

      result = described_class.call(request: request)

      expect(result).to_not be_success
      expect(result.failure_reason).to eq expected_reason
    end
  end
end
