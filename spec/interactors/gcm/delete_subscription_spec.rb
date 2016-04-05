require 'rails_helper'

describe GCM::DeleteSubscription do
  it_behaves_like 'a device subscription focused interactor', :gcm

  context 'when the provided bundle_identifier is registered with GCM' do
    let!(:registered_application) { create(:sns_application, :gcm) }
    let(:registered_bundle_identifier) { registered_application.bundle_identifier }

    context 'when a GCM device subscription exists for the device token and bundle identifier' do
      let!(:sns_client) { Aws::SNS::Client.new }
      let!(:existing_subscription) { create(:device_subscription, :gcm, sns_application: registered_application) }

      let(:call_interactor) do
        described_class.call({
          current_user_id: 1,
          bundle_identifier: registered_bundle_identifier,
          platform_device_identifier: existing_subscription.platform_device_identifier
        })
      end

      before do
        allow(Aws::SNS::Client).to receive(:new).and_return(sns_client)
      end

      it 'deletes the platform endpoint from SNS' do
        expect(sns_client).to receive(:delete_endpoint).with({
          endpoint_arn: existing_subscription.endpoint_arn
        }).and_call_original

        call_interactor
      end

      context 'and the SNS endpoint deletion fails' do
        let(:expected_error_message) { 'Original exception error message' }
        before do
          exception = Aws::SNS::Errors::InvalidParameterException.new(nil, expected_error_message)
          sns_client.stub_responses(:delete_endpoint, exception)
        end

        it 'fails the interactor with the SNS error message' do
          result = call_interactor

          expect(result).to_not be_success
          expect(result.message).to eq expected_error_message
        end

        it 'does not delete the device subscription' do
          expect {
            call_interactor
          }.to_not change { DeviceSubscription.count }
        end

        it 'tracks the failure' do
          expect(GcmSubscriptionMetric).to receive(:track_deletion_failure)
          expect(GcmSubscriptionMetric).to_not receive(:track_deletion_success)
          call_interactor
        end
      end

      context 'and the SNS endpoint deletion succeeds' do
        it 'deletes the device subscription' do
          expect {
            call_interactor
          }.to change { DeviceSubscription.count }.by(-1)
        end

        it 'tracks the success' do
          expect(GcmSubscriptionMetric).to receive(:track_deletion_success)
          expect(GcmSubscriptionMetric).to_not receive(:track_deletion_failure)
          call_interactor
        end
      end
    end

    context 'when a GCM device subscription does not exist for the device token and bundle identifier' do
      it 'succeeds with a not found message' do
        result = described_class.call({
          bundle_identifier: registered_bundle_identifier,
          platform_device_identifier: Faker::Ello.android_registration_id
        })

        expect(result).to be_success
        expect(result.message).to eq 'Subscription could not be found with the input parameters'
      end
    end
  end

end
