require 'rails_helper'

describe APNS::CreateSubscription do
  it_behaves_like 'a device subscription focused interactor', :apns

  context 'when the provided bundle_identifier is registered with APNS' do
    let!(:registered_application) { create(:sns_application, :apns) }
    let(:registered_bundle_identifier) { registered_application.bundle_identifier }

    context 'when an APNS device subscription already exists with the device token and bundle identifier' do
      let!(:existing_subscription) { create(:device_subscription, :apns, sns_application: registered_application) }

      it 'does not create a new subscription' do
        expect {
          described_class.call({
            logged_in_user_id: existing_subscription.logged_in_user_id,
            bundle_identifier: registered_bundle_identifier,
            platform_device_identifier: existing_subscription.platform_device_identifier
          })
        }.to_not change { DeviceSubscription.count }
      end

      it 'does not create a new platform endpoint on SNS' do
        expect(SnsService).to_not receive(:create_subscription_endpoint)

        described_class.call({
          logged_in_user_id: existing_subscription.logged_in_user_id,
          bundle_identifier: registered_bundle_identifier,
          platform_device_identifier: existing_subscription.platform_device_identifier
        })
      end

      context 'and the currently logged in user has changed' do
        it 'links the subscription to the new logged in user' do
          new_user_id = 2000
          expect {
            described_class.call({
              logged_in_user_id: new_user_id,
              bundle_identifier: registered_bundle_identifier,
              platform_device_identifier: existing_subscription.platform_device_identifier
            })
          }.to change { existing_subscription.reload.logged_in_user_id }.to(new_user_id)
        end
      end

      context 'and the subscription is currently disabled' do
        before { existing_subscription.update_attribute(:enabled, false) }
        it 're-enables the subscription' do
          expect {
            described_class.call({
              logged_in_user_id: existing_subscription.logged_in_user_id,
              bundle_identifier: registered_bundle_identifier,
              platform_device_identifier: existing_subscription.platform_device_identifier
            })
          }.to change { existing_subscription.reload.enabled }.to(true)
        end
      end
    end

    context 'when an APNS device subscription does not exist with the device token and bundle identifier' do
      let!(:sns_client) { Aws::SNS::Client.new }

      before do
        allow(Aws::SNS::Client).to receive(:new).and_return(sns_client)
      end

      it 'creates a new platform endpoint with SNS' do
        expected_device_token = Faker::Ello.ios_device_token
        expected_application_arn = registered_application.application_arn

        expect(sns_client).to receive(:create_platform_endpoint).with({
          platform_application_arn: expected_application_arn,
          token: expected_device_token,
          attributes: { 'Enabled' => 'true' }
        }).and_call_original

        described_class.call({
          logged_in_user_id: 1,
          bundle_identifier: registered_bundle_identifier,
          platform_device_identifier: expected_device_token
        })
      end

      context 'and the SNS platform endpoint creation fails' do
        let(:expected_error_message) { 'Original exception error message' }
        before do
          exception = SnsService::ServiceError.new(expected_error_message)
          allow(SnsService).to receive(:create_subscription_endpoint).and_raise(exception)
        end

        it 'fails the interactor with the error message' do
          result = described_class.call({
            logged_in_user_id: 1,
            bundle_identifier: registered_bundle_identifier,
            platform_device_identifier: Faker::Ello.ios_device_token
          })

          expect(result).to_not be_success
          expect(result.message).to eq expected_error_message
        end

        it 'does not create a new device subscription' do
          expect {
            described_class.call({
              logged_in_user_id: 1,
              bundle_identifier: registered_bundle_identifier,
              platform_device_identifier: Faker::Ello.ios_device_token
            })
          }.to_not change { DeviceSubscription.count }
        end
      end

      context 'and the SNS platform endpoint creation succeeds' do
        let(:newly_created_endpoint_arn) { 'arn.from.create' }
        before do
          allow(SnsService).to receive(:create_subscription_endpoint).and_return(newly_created_endpoint_arn)
        end

        it 'creates a new device subscription' do
          expect {
            described_class.call({
              logged_in_user_id: 1,
              bundle_identifier: registered_bundle_identifier,
              platform_device_identifier: Faker::Ello.ios_device_token
            })
          }.to change { DeviceSubscription.count }.by(1)
        end

        it 'exposes the new device subscription on the result' do
          result = described_class.call({
            logged_in_user_id: 1,
            bundle_identifier: registered_bundle_identifier,
            platform_device_identifier: Faker::Ello.ios_device_token
          })

          expect(result.subscription).to be_instance_of(DeviceSubscription)
        end

        it 'associates the new SNS platform endpoint to the new subscription' do
          described_class.call({
            logged_in_user_id: 1,
            bundle_identifier: registered_bundle_identifier,
            platform_device_identifier: Faker::Ello.ios_device_token
          })

          expect(DeviceSubscription.last.endpoint_arn).to eq newly_created_endpoint_arn
        end
      end
    end
  end

end
