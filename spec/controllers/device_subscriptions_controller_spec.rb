require 'rails_helper'

describe DeviceSubscriptionsController, type: :request do

  describe 'POST #create' do
    context 'with content-type HTML' do
      it 'fails with status code 406' do
        post create_device_subscription_path

        expect(response.code).to eq '406'
      end
    end

    context 'using binary content-type' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/octet-stream', 'ACCEPT' => 'application/octet-stream' } }

      let(:create_device_subscription_request) do
        ElloProtobufs::NotificationService::CreateDeviceSubscriptionRequest.new({
          platform: ElloProtobufs::NotificationPlatform::APNS,
          bundle_identifier: 'co.ello.ellodev',
          platform_device_identifier: '12345',
          logged_in_user_id: 1
        })
      end


      context 'when the creation succeeds' do
        before do
          successful_context = double('Context', success?: true, failure?: false)
          allow(CreateDeviceSubscription).to receive(:call).and_return(successful_context)

          post create_device_subscription_path, create_device_subscription_request.encode, headers
        end

        it 'passes the required params and request body to the interactor' do
          expect(CreateDeviceSubscription).to have_received(:call).with({
            request: create_device_subscription_request
          })
        end

        it 'succeeds with status code 200' do
          expect(response.code).to eq '200'
        end

        it 'responds with a successful response object' do
          resp = ElloProtobufs::NotificationService::ServiceResponse.decode(response.body)
          expect(resp).to be_success
        end
      end

      context 'when the creation fails' do
        let(:expected_failure_reason) { ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_NOTIFICATION_PLATFORM }

        before do
          failed_context = double('Context', success?: false, failure?: true, failure_reason: expected_failure_reason)
          allow(CreateDeviceSubscription).to receive(:call).and_return(failed_context)

          post create_device_subscription_path, create_device_subscription_request.encode, headers
        end

        it 'fails with status code 403' do
          expect(response.code).to eq '403'
        end

        it 'includes the correct failure reason in the response' do
          resp = ElloProtobufs::NotificationService::ServiceResponse.decode(response.body)
          expect(resp.failure_reason).to eq(expected_failure_reason)
        end
      end
    end
  end

  describe 'POST #delete' do
    context 'with content-type HTML' do
      it 'fails with status code 406' do
        post delete_device_subscription_path

        expect(response.code).to eq '406'
      end
    end

    context 'using binary content-type' do
      let(:headers) { { 'CONTENT_TYPE' => 'application/octet-stream', 'ACCEPT' => 'application/octet-stream' } }

      let(:delete_device_subscription_request) do
        ElloProtobufs::NotificationService::DeleteDeviceSubscriptionRequest.new({
          platform: ElloProtobufs::NotificationPlatform::APNS,
          bundle_identifier: 'co.ello.ellodev',
          platform_device_identifier: '12345',
          logged_in_user_id: 1
        })
      end


      context 'when the deletion succeeds' do
        before do
          successful_context = double('Context', success?: true, failure?: false)
          allow(DeleteDeviceSubscription).to receive(:call).and_return(successful_context)

          post delete_device_subscription_path, delete_device_subscription_request.encode, headers
        end

        it 'passes the required params and request body to the interactor' do
          expect(DeleteDeviceSubscription).to have_received(:call).with({
            request: delete_device_subscription_request
          })
        end

        it 'succeeds with status code 200' do
          expect(response.code).to eq '200'
        end

        it 'responds with a successful response object' do
          resp = ElloProtobufs::NotificationService::ServiceResponse.decode(response.body)
          expect(resp).to be_success
        end
      end

      context 'when the deletion fails' do
        let(:expected_failure_reason) { ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_NOTIFICATION_PLATFORM }

        before do
          failed_context = double('Context', success?: false, failure?: true, failure_reason: expected_failure_reason)
          allow(DeleteDeviceSubscription).to receive(:call).and_return(failed_context)

          post delete_device_subscription_path, delete_device_subscription_request.encode, headers
        end

        it 'fails with status code 403' do
          expect(response.code).to eq '403'
        end

        it 'includes the correct failure reason in the response' do
          resp = ElloProtobufs::NotificationService::ServiceResponse.decode(response.body)
          expect(resp.failure_reason).to eq(expected_failure_reason)
        end
      end
    end
  end

end
