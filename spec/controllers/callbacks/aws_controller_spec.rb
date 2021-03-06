# frozen_string_literal: true

require 'rails_helper'
require 'sucker_punch/testing/inline'

describe Callbacks::AwsController, type: :request do
  before do
    allow_any_instance_of(Aws::SNS::Client).to receive(:confirm_subscription)
    allow(SnsService).to receive(:unsubscribe_from_topic)
  end

  let(:headers) { {} }

  describe 'POST #push_failed' do
    context 'when verifying subscription' do
      before do
        allow_any_instance_of(Aws::SNS::Client).to receive(:confirm_subscription).and_return(confirmation_response)
      end

      let(:body) { { Token: '123', TopicArn: '456' } }
      let(:headers) do
        {
          'x-amz-sns-message-type' => 'SubscriptionConfirmation',
          'Content-Type' => 'application/json',
          'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin')
        }
      end

      context 'when the verification is successful' do
        let(:confirmation_response) do
          instance_double('Seahorse::Client::Response', successful?: true)
        end

        it 'returns a 200' do
          post '/callbacks/aws/push_failed', body.to_json, headers
          expect(response.status).to be(200)
        end
      end

      context 'when the verification is unsuccessful' do
        let(:confirmation_response) do
          instance_double('Seahorse::Client::Response', successful?: false)
        end

        it 'returns a 406' do
          post '/callbacks/aws/push_failed', body.to_json, headers
          expect(response.status).to be(406)
        end
      end
    end

    context 'with a validated message' do
      before do
        allow_any_instance_of(Aws::SNS::MessageVerifier).to receive(:authentic?).and_return(true)
      end

      context 'when message is a failed push notification' do
        let!(:subscription) do
          create(:device_subscription, :gcm,
                 platform_device_identifier: '123',
                 announcement_subscription_arn: 'arn:sns:abc123')
        end

        let(:headers) do
          {
            'x-amz-sns-message-type' => 'Notification',
            'Content-Type' => 'application/json',
            'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin')
          }
        end

        let(:body) { { delivery: { token: '123' }, status: 'FAILURE' } }

        it 'deletes the device subscription' do
          expect(DeviceSubscription.find(subscription.id)).to be_truthy
          post '/callbacks/aws/push_failed', body.to_json, headers
          expect(response.status).to be(200)
          expect(DeviceSubscription.find_by(id: subscription.id)).to be_nil
        end

        it 'removes the announcement topic subscription' do
          expect(DeviceSubscription.find(subscription.id)).to be_truthy
          expect(SnsService).to receive(:unsubscribe_from_topic).with('arn:sns:abc123')
          post '/callbacks/aws/push_failed', body.to_json, headers
          expect(response.status).to be(200)
          expect(DeviceSubscription.find_by(id: subscription.id)).to be_nil
        end
      end

      context 'when message is NOT a failed push notification' do
        let!(:subscription) do
          create(:device_subscription, :gcm, platform_device_identifier: '123')
        end

        let(:headers) do
          {
            'Content-Type' => 'application/json',
            'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin')
          }
        end

        let(:body) { { deliver: { token: '123' }, status: 'NOT FAILURE' } }

        it 'does not delete a device subscription' do
          expect(DeviceSubscription.find(subscription.id)).to be_truthy
          post '/callbacks/aws/push_failed', body.to_json, headers
          expect(response.status).to be(200)
          expect(DeviceSubscription.find(subscription.id)).to be_truthy
        end
      end
    end

    context 'with an unvalidated message' do
      let!(:subscription) do
        create(:device_subscription, :gcm, platform_device_identifier: '123')
      end

      let(:headers) do
        {
          'x-amz-sns-message-type' => 'Notification',
          'Content-Type' => 'application/json',
          'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'admin')
        }
      end

      before do
        allow_any_instance_of(Aws::SNS::MessageVerifier).to receive(:authentic?).and_return(false)
      end

      it 'does not delete a device subscription' do
        expect(DeviceSubscription.find(subscription.id)).to be_truthy
        post '/callbacks/aws/push_failed', body.to_json, headers
        expect(response.status).to be(406)
        expect(DeviceSubscription.find(subscription.id)).to be_truthy
      end
    end
  end
end
