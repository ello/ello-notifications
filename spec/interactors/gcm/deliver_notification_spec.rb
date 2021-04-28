# frozen_string_literal: true

require 'rails_helper'

describe GCM::DeliverNotification do
  context 'when called without an endpoint_arn' do
    it 'fails with an error message' do
      result = described_class.call(notification: Notification.new)

      expect(result).not_to be_success
      expect(result.message).to eq 'Missing required argument: endpoint_arn'
    end
  end

  context 'when called without a notification' do
    it 'fails with an error message' do
      result = described_class.call(endpoint_arn: Faker::Ello.sns_gcm_endpoint_arn)

      expect(result).not_to be_success
      expect(result.message).to eq 'Missing required argument: notification'
    end
  end

  context 'when called with required arguments' do
    let(:sns_client) { Aws::SNS::Client.new }

    let(:notification) { build(:notification, metadata: { some_key: 'value' }) }

    before { allow(Aws::SNS::Client).to receive(:new).and_return(sns_client) }

    it 'delivers the notification to the desired endpoint via the SNS service' do
      endpoint_arn = Faker::Ello.sns_gcm_endpoint_arn
      expect(SnsService).to receive(:deliver_notification).with(endpoint_arn, anything)
      described_class.call({
                             endpoint_arn: endpoint_arn,
                             notification: Notification.new
                           })
    end

    context 'when configured' do
      let(:production_endpoint_arn) { Faker::Ello.sns_gcm_endpoint_arn }
      let(:notification) { build(:notification, metadata: { some_key: 'value' }) }

      let(:call_interactor) do
        described_class.call({
                               endpoint_arn: production_endpoint_arn,
                               notification: notification,
                               use_sandbox: false
                             })
      end

      it 'nests the notification data inside the production message container' do
        expected_message = {
          'GCM' => {
            data: {
              some_key: 'value',
              title: notification.title,
              body: notification.body
            }
          }.to_json
        }

        expect(SnsService).to receive(:deliver_notification).with(anything, expected_message)
        call_interactor
      end

      context 'when the notification should not include an alert' do
        let(:notification) { build(:notification, :badge_count_only) }

        it 'does not include the alert in the payload' do
          expected_message = {
            'GCM' => {
              data: {}
            }.to_json
          }

          expect(SnsService).to receive(:deliver_notification).with(anything, expected_message)
          call_interactor
        end
      end
    end

    context 'when the delivery fails' do
      let(:exception) { SnsService::ServiceError.new('error') }

      before { allow(SnsService).to receive(:deliver_notification).and_raise(exception) }

      it 'tracks the failure' do
        expect(GcmDeliveryMetric).to receive(:track_delivery_failure)
        expect(GcmDeliveryMetric).not_to receive(:track_delivery_success)

        described_class.call(
          endpoint_arn: Faker::Ello.sns_gcm_endpoint_arn,
          notification: Notification.new
        )
      end

      it 'fails the interactor' do
        result = described_class.call(
          endpoint_arn: Faker::Ello.sns_gcm_endpoint_arn,
          notification: Notification.new
        )

        expect(result).to be_failure
        expect(result.message).to eq exception.message
      end
    end

    context 'when the delivery succeeds' do
      before { allow(SnsService).to receive(:deliver_notification) }

      it 'tracks the success' do
        expect(GcmDeliveryMetric).to receive(:track_delivery_success)
        expect(GcmDeliveryMetric).not_to receive(:track_delivery_failure)

        described_class.call(
          endpoint_arn: Faker::Ello.sns_gcm_endpoint_arn,
          notification: Notification.new
        )
      end
    end
  end

end
