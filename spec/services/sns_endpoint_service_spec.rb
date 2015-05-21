require 'rails_helper'

describe SnsService do
  let!(:sns_client) { Aws::SNS::Client.new }
  before { allow(Aws::SNS::Client).to receive(:new).and_return(sns_client) }

  describe '.create_subscription_endpoint' do
    let(:new_subscription) { build(:device_subscription, :apns, :creatable_on_sns) }

    it 'creates a new platform endpoint with SNS' do
      expected_device_token = new_subscription.platform_device_identifier
      expected_application_arn = new_subscription.sns_application.application_arn

      expect(sns_client).to receive(:create_platform_endpoint).with({
        platform_application_arn: expected_application_arn,
        token: expected_device_token,
        attributes: { 'Enabled' => 'true' }
      }).and_call_original

      described_class.create_subscription_endpoint(new_subscription)
    end

    context 'when the subscription is not creatable on SNS' do
      let(:uncreatable_subscription) { DeviceSubscription.new }

      it 'raises a service error with the relevant validation error' do
        uncreatable_subscription.valid? # necessary to create errors on model
        message = "Cannot create device subscription: " + uncreatable_subscription.errors.full_messages.first

        expect {
          described_class.create_subscription_endpoint(uncreatable_subscription)
        }.to raise_error { |error|
          expect(error).to be_a(SnsService::ServiceError)
          expect(error.message).to eq message
        }
      end

      it 'does not attempt to create the subscripton on SNS' do
        expect(sns_client).to_not receive(:create_platform_endpoint)
        begin
          described_class.create_subscription_endpoint(uncreatable_subscription)
        rescue SnsService::ServiceError => _
          # noop
        end
      end
    end

    context 'when the SNS platform endpoint creation fails' do
      it 'raises a service error with the original exception and exception message' do
        original_error_message = 'Original exception error message'
        original_exception = Aws::SNS::Errors::InvalidParameterException.new(nil, original_error_message)

        sns_client.stub_responses(:create_platform_endpoint, original_exception)

        expect {
          described_class.create_subscription_endpoint(new_subscription)
        }.to raise_error { |error|
          expect(error).to be_a(SnsService::ServiceError)
          expect(error.message).to eq original_error_message
          expect(error.original_exception).to eq original_exception
        }
      end
    end

    context 'when the SNS platform endpoint creation succeeds' do
      it 'returns the newly created endpoint_arn' do
        newly_created_endpoint_arn = 'arn.from.create'
        sns_client.stub_responses(:create_platform_endpoint, endpoint_arn: newly_created_endpoint_arn)

        result = described_class.create_subscription_endpoint(new_subscription)
        expect(result).to eq newly_created_endpoint_arn
      end
    end
  end

  describe '.delete_subscription_endpoint' do
    let!(:existing_subscription) { build_stubbed(:device_subscription, :apns) }

    it 'deletes the platform endpoint from SNS' do
      expect(sns_client).to receive(:delete_endpoint).with({
        endpoint_arn: existing_subscription.endpoint_arn
      }).and_call_original

      described_class.delete_subscription_endpoint(existing_subscription)
    end

    context 'when the SNS endpoint deletion fails' do
      it 'raises a service error with the original exception and exception message' do
        original_error_message = 'Original exception error message'
        original_exception = Aws::SNS::Errors::InvalidParameterException.new(nil, original_error_message)

        sns_client.stub_responses(:delete_endpoint, original_exception)

        expect {
          described_class.delete_subscription_endpoint(existing_subscription)
        }.to raise_error { |error|
          expect(error).to be_a(SnsService::ServiceError)
          expect(error.message).to eq original_error_message
          expect(error.original_exception).to eq original_exception
        }
      end
    end
  end

  describe '.deliver_notification' do
    it 'delivers a notification payload with SNS' do
      endpoint_arn = Faker::Ello.sns_apns_endpoint_arn
      notification = { foo: 'bar' }

      expect(sns_client).to receive(:publish).with({
        target_arn: endpoint_arn,
        message_structure: 'json',
        message: notification.to_json
      }).and_call_original

      described_class.deliver_notification(endpoint_arn, notification)
    end

    context 'when the SNS platform publish fails' do
      it 'raises a service error with the original exception and exception message' do
        original_error_message = 'Original exception error message'
        original_exception = Aws::SNS::Errors::InvalidParameterException.new(nil, original_error_message)

        sns_client.stub_responses(:publish, original_exception)

        expect {
          described_class.deliver_notification('endpoint', {})
        }.to raise_error { |error|
          expect(error).to be_a(SnsService::ServiceError)
          expect(error.message).to eq original_error_message
          expect(error.original_exception).to eq original_exception
        }
      end
    end
  end
end
