require 'rails_helper'

describe GCM::CreateSubscription do
  it_behaves_like 'a device subscription focused interactor', :gcm

  context 'when the provided bundle_identifier is registered with GCM' do
    let!(:registered_application) { create(:sns_application, :gcm) }
    let(:registered_bundle_identifier) { registered_application.bundle_identifier }
    let(:marketing_version) { '6.6.6' }
    let(:build_version) { '1234567' }

    context 'when a GCM device subscription already exists with the device token and bundle identifier' do
      let!(:existing_subscription) { create(:device_subscription, :gcm, sns_application: registered_application) }

      let(:call_interactor) do
        described_class.call({
                                 logged_in_user_id: existing_subscription.logged_in_user_id,
                                 bundle_identifier: registered_bundle_identifier,
                                 platform_device_identifier: existing_subscription.platform_device_identifier,
                                 marketing_version: marketing_version,
                                 build_version: build_version
                             })
      end

      it 'does not create a new subscription' do
        expect {
          call_interactor
        }.to_not change { DeviceSubscription.count }
      end

      it 'does not create a new platform endpoint on SNS' do
        expect(SnsService).to_not receive(:create_subscription_endpoint)

        call_interactor
      end

      it 'updates the marketing version field to the supplied value' do
        expect {
          call_interactor
        }.to change { existing_subscription.reload.marketing_version }.to(marketing_version)
      end

      it 'updates the build version field to the supplied value' do
        expect {
          call_interactor
        }.to change { existing_subscription.reload.build_version }.to(build_version)
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

        it 're-enables the subscription via SNS' do
          expect(SnsService).to receive(:enable_subscription_endpoint).with(existing_subscription).
              and_call_original

          call_interactor
        end

        context 'when the SNS re-enable fails' do
          let(:expected_error_message) { 'Original exception error message' }
          before do
            exception = SnsService::ServiceError.new(expected_error_message)
            allow(SnsService).to receive(:enable_subscription_endpoint).and_raise(exception)
          end

          it 'fails the interactor with the error message' do
            result = call_interactor

            expect(result).to_not be_success
            expect(result.message).to eq expected_error_message
          end

          it 'does not re-enable the subscription locally' do
            expect {
              call_interactor
            }.to_not change { existing_subscription.reload.enabled }
          end

          it 'tracks the failure' do
            expect(ApnsSubscriptionMetric).to receive(:track_creation_failure)
            expect(ApnsSubscriptionMetric).to_not receive(:track_creation_success)
            call_interactor
          end
        end

        context 'when the SNS re-enable succeeds' do
          it 're-enables the subscription locally' do
            expect {
              call_interactor
            }.to change { existing_subscription.reload.enabled }.to(true)
          end

          it 'tracks the success' do
            expect(ApnsSubscriptionMetric).to receive(:track_creation_success).with('reused')
            expect(ApnsSubscriptionMetric).to_not receive(:track_creation_failure)
            call_interactor
          end
        end
      end
    end

    context 'when an APNS device subscription does not exist with the device token and bundle identifier' do
      let(:user_id) { 1 }
      let(:device_token) { Faker::Ello.ios_device_token }
      let(:call_interactor) do
        described_class.call({
                                 logged_in_user_id: user_id,
                                 bundle_identifier: registered_bundle_identifier,
                                 platform_device_identifier: device_token,
                                 marketing_version: marketing_version,
                                 build_version: build_version
                             })
      end

      it 'creates a new platform endpoint with SNS' do
        expect(SnsService).to receive(:create_subscription_endpoint).with(kind_of(DeviceSubscription)).
            and_call_original

        call_interactor
      end

      context 'and the SNS platform endpoint creation fails' do
        let(:expected_error_message) { 'Original exception error message' }
        before do
          exception = SnsService::ServiceError.new(expected_error_message)
          allow(SnsService).to receive(:create_subscription_endpoint).and_raise(exception)
        end

        it 'fails the interactor with the error message' do
          result = call_interactor

          expect(result).to_not be_success
          expect(result.message).to eq expected_error_message
        end

        it 'does not create a new device subscription' do
          expect {
            call_interactor
          }.to_not change { DeviceSubscription.count }
        end

        it 'tracks the failure' do
          expect(GcmSubscriptionMetric).to receive(:track_creation_failure)
          expect(GcmSubscriptionMetric).to_not receive(:track_creation_success)
          call_interactor
        end
      end

      context 'and the SNS platform endpoint creation succeeds' do
        let(:newly_created_endpoint_arn) { 'arn.from.create' }
        before do
          allow(SnsService).to receive(:create_subscription_endpoint).and_return(newly_created_endpoint_arn)
        end

        it 'creates a new device subscription' do
          expect {
            call_interactor
          }.to change { DeviceSubscription.count }.by(1)
        end

        it 'exposes the new device subscription on the result' do
          result = call_interactor

          expect(result.subscription).to be_instance_of(DeviceSubscription)
        end

        it 'associates the new subscription to the appropriate linked attributes' do
          call_interactor

          sub = DeviceSubscription.last
          expect(sub.logged_in_user_id).to eq(user_id)
          expect(sub.platform_device_identifier).to eq(device_token)
          expect(sub.endpoint_arn).to eq newly_created_endpoint_arn
          expect(sub.sns_application).to eq(registered_application)
          expect(sub.marketing_version).to eq(marketing_version)
          expect(sub.build_version).to eq(build_version)
        end

        it 'tracks the success' do
          expect(GcmSubscriptionMetric).to receive(:track_creation_success).with('new')
          expect(GcmSubscriptionMetric).to_not receive(:track_creation_failure)
          call_interactor
        end
      end
    end
  end

end
