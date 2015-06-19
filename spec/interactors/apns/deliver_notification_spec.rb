require 'rails_helper'

describe APNS::DeliverNotification do
  context 'when called without an endpoint_arn' do
    it 'fails with an error message' do
      result = described_class.call(notification: Notification.new)

      expect(result).to_not be_success
      expect(result.message).to eq 'Missing required argument: endpoint_arn'
    end
  end

  context 'when called without a notification' do
    it 'fails with an error message' do
      result = described_class.call(endpoint_arn: Faker::Ello.sns_apns_endpoint_arn)

      expect(result).to_not be_success
      expect(result.message).to eq 'Missing required argument: notification'
    end
  end

  context 'when called with required arguments' do
    let(:sns_client) { Aws::SNS::Client.new }

    let(:notification) { build(:notification, metadata: { some_key: 'value' }) }

    before { allow(Aws::SNS::Client).to receive(:new).and_return(sns_client) }

    it 'delivers the notification to the desired endpoint via the SNS service' do
      endpoint_arn = Faker::Ello.sns_apns_endpoint_arn
      expect(SnsService).to receive(:deliver_notification).with(endpoint_arn, anything)
      described_class.call({
        endpoint_arn: endpoint_arn,
        notification: Notification.new
      })
    end

    context 'when configured to use the sandbox' do
      let(:sandbox_endpoint_arn) { Faker::Ello.sns_apns_endpoint_arn(sandbox: true) }

      it 'nests the notification data inside the sandbox message container' do
        notification = build(:notification, metadata: { some_key: 'value' })
        expected_message = {
          'APNS_SANDBOX' => {
            aps: {
              alert: {
                title: notification.title,
                body: notification.body
              }
            },
            some_key: 'value'
          }.to_json
        }

        expect(SnsService).to receive(:deliver_notification).with(anything, expected_message)

        described_class.call({
          endpoint_arn: sandbox_endpoint_arn,
          notification: notification,
          use_sandbox: true
        })
      end
    end

    context 'when configured not to use the sandbox' do
      let(:production_endpoint_arn) { Faker::Ello.sns_apns_endpoint_arn(sandbox: false) }
      it 'nests the notification data inside the production message container' do
        notification = build(:notification, metadata: { some_key: 'value' })
        expected_message = {
          'APNS' => {
            aps: {
              alert: {
                title: notification.title,
                body: notification.body
              }
            },
            some_key: 'value'
          }.to_json
        }

        expect(SnsService).to receive(:deliver_notification).with(anything, expected_message)

        described_class.call({
          endpoint_arn: production_endpoint_arn,
          notification: notification,
          use_sandbox: false
        })
      end
    end

    context 'when the delivery fails' do
      let(:exception) { SnsService::ServiceError.new('error') }
      before { allow(SnsService).to receive(:deliver_notification).and_raise(exception) }

      it 'tracks the failure' do
        expect(ApnsDeliveryMetric).to receive(:track_delivery_failure)
        expect(ApnsDeliveryMetric).to_not receive(:track_delivery_success)

        described_class.call(
          endpoint_arn: Faker::Ello.sns_apns_endpoint_arn,
          notification: Notification.new
        )
      end

      it 'fails the interactor' do
        result = described_class.call(
          endpoint_arn: Faker::Ello.sns_apns_endpoint_arn,
          notification: Notification.new
        )

        expect(result).to be_failure
        expect(result.message).to eq exception.message
      end
    end

    context 'when the delivery succeeds' do
      before { allow(SnsService).to receive(:deliver_notification) }

      it 'tracks the success' do
        expect(ApnsDeliveryMetric).to receive(:track_delivery_success)
        expect(ApnsDeliveryMetric).to_not receive(:track_delivery_failure)

        described_class.call(
          endpoint_arn: Faker::Ello.sns_apns_endpoint_arn,
          notification: Notification.new
        )
      end
    end
  end

end
