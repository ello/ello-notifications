require 'rails_helper'

describe APNS::DeleteSubscription do
  it_behaves_like 'a device subscription focused interactor', :apns

  context 'when the provided bundle_identifier is registered with APNS' do
    let!(:registered_application) { create(:sns_application, :apns) }
    let(:registered_bundle_identifier) { registered_application.bundle_identifier }

    context 'when an APNS device subscription exists for the device token and bundle identifier' do
      let!(:sns_client) { Aws::SNS::Client.new }
      let!(:existing_subscription) { create(:device_subscription, :apns, sns_application: registered_application) }

      before do
        allow(Aws::SNS::Client).to receive(:new).and_return(sns_client)
      end

      it 'deletes the platform endpoint from SNS' do
        expect(sns_client).to receive(:delete_endpoint).with({
          endpoint_arn: existing_subscription.endpoint_arn
        }).and_call_original

        described_class.call({
          current_user_id: 1,
          bundle_identifier: registered_bundle_identifier,
          platform_device_identifier: existing_subscription.platform_device_identifier
        })
      end

      context 'and the SNS endpoint deletion fails' do
        let(:expected_error_message) { 'Original exception error message' }
        before do
          exception = Aws::SNS::Errors::InvalidParameterException.new(nil, expected_error_message)
          sns_client.stub_responses(:delete_endpoint, exception)
        end

        it 'fails the interactor with the SNS error message' do
          result = described_class.call({
            current_user_id: 1,
            bundle_identifier: registered_bundle_identifier,
            platform_device_identifier: existing_subscription.platform_device_identifier
          })

          expect(result).to_not be_success
          expect(result.message).to eq expected_error_message
        end

        it 'does not delete the device subscription' do
          expect {
            described_class.call({
              current_user_id: 1,
              bundle_identifier: registered_bundle_identifier,
              platform_device_identifier: existing_subscription.platform_device_identifier
            })
          }.to_not change { DeviceSubscription.count }
        end
      end

      context 'and the SNS endpoint deletion succeeds' do
        it 'deletes the device subscription' do
          expect {
            described_class.call({
              current_user_id: 1,
              bundle_identifier: registered_bundle_identifier,
              platform_device_identifier: existing_subscription.platform_device_identifier
            })
          }.to change { DeviceSubscription.count }.by(-1)
        end
      end
    end

    context 'when an APNS device subscription does not exist for the device token and bundle identifier' do
      it 'succeeds with a not found message' do
        result = described_class.call({
          bundle_identifier: registered_bundle_identifier,
          platform_device_identifier: FFaker::Ello.ios_device_token
        })

        expect(result).to be_success
        expect(result.message).to eq 'Subscription could not be found with the input paramaters'
      end
    end
  end

end
