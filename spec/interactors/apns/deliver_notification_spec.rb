require 'rails_helper'

describe APNS::DeliverNotification do
  context 'when called without an endpoint_arn' do
    it 'fails with an error message' do
      result = described_class.call(notification: Notification.new, use_sandbox: false)

      expect(result).to_not be_success
      expect(result.message).to eq 'Missing required argument: endpoint_arn'
    end
  end

  context 'when called without a notification' do
    it 'fails with an error message' do
      result = described_class.call(endpoint_arn: 'arn:aws:sns:some-endpoint', use_sandbox: false)

      expect(result).to_not be_success
      expect(result.message).to eq 'Missing required argument: notification'
    end
  end

  context 'when called without a use_sandbox setting' do
    it 'fails with an error message' do
      result = described_class.call(endpoint_arn: 'arn:aws:sns:some-endpoint', notification: Notification.new)

      expect(result).to_not be_success
      expect(result.message).to eq 'Missing required argument: use_sandbox'
    end
  end

  context 'when called with required arguments' do
    let(:sns_client) { Aws::SNS::Client.new }

    let(:endpoint_arn) { 'arn:aws:sns:some-endpoint' }
    let(:notification) { build(:notification, metadata: { some_key: 'value' }) }

    before { allow(Aws::SNS::Client).to receive(:new).and_return(sns_client) }

    it 'delivers the notification with SNS' do
      expect(sns_client).to receive(:publish).with({
        target_arn: endpoint_arn,
        message_structure: 'json',
        message: kind_of(String)
      })

      described_class.call({
        endpoint_arn: endpoint_arn,
        notification: Notification.new,
        use_sandbox: true
      })
    end

    context 'when configured to use the sandbox' do
      it 'nests the notification data inside the sandbox message container' do
        notification = build(:notification, metadata: { some_key: 'value' })
        expected_message = {
          APNS_SANDBOX: {
            aps: {
              alert: {
                title: notification.title,
                body: notification.body
              }
            },
            some_key: 'value'
          }.to_json
        }.to_json

        expect(sns_client).to receive(:publish).with(hash_including({
          message: expected_message
        }))

        described_class.call({
          endpoint_arn: endpoint_arn,
          notification: notification,
          use_sandbox: true
        })
      end
    end

    context 'when configured not to use the sandbox' do
      it 'nests the notification data inside the production message container' do
        notification = build(:notification, metadata: { some_key: 'value' })
        expected_message = {
          APNS: {
            aps: {
              alert: {
                title: notification.title,
                body: notification.body
              }
            },
            some_key: 'value'
          }.to_json
        }.to_json

        expect(sns_client).to receive(:publish).with(hash_including({
          message: expected_message
        }))

        described_class.call({
          endpoint_arn: endpoint_arn,
          notification: notification,
          use_sandbox: false
        })
      end
    end
  end

end
