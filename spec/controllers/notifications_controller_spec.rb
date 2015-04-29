require 'rails_helper'

describe NotificationsController, type: :request do

  describe 'POST #create' do
    context 'with default content-type' do
      it 'fails with status code 406' do
        post notifications_path

        expect(response.code).to eq '406'
      end
    end

    context 'using binary content-type' do
      before do
        # short-hand aliases for test readability purposes
        stub_const('CreateNotificationFailureReason', ElloProtobufs::NotificationService::CreateNotificationFailureReason)
        stub_const('CreateNotificationRequest', ElloProtobufs::NotificationService::CreateNotificationRequest)
        stub_const('CreateNotificationResponse', ElloProtobufs::NotificationService::CreateNotificationResponse)
        stub_const('NotificationType', ElloProtobufs::NotificationType)
      end

      let(:headers) { { 'CONTENT_TYPE' => 'application/octet-stream', 'ACCEPT' => 'application/octet-stream' } }

      let(:create_notification_request) do
        CreateNotificationRequest.new({
          type: ElloProtobufs::NotificationType::FOLLOWER,
          destination_user_id: 2,
          user: create(:protobuf_user)
        })
      end

      context 'when the creation succeeds' do
        before do
          successful_context = double('Context', success?: true, failure?: false)
          allow(CreateNotification).to receive(:call).and_return(successful_context)

          post notifications_path, create_notification_request.encode, headers
        end

        it 'passes the required params and request body to the interactor' do
          expect(CreateNotification).to have_received(:call).with({
            request: create_notification_request
          })
        end

        it 'succeeds with status code 200' do
          expect(response.code).to eq '200'
        end

        it 'responds with a successful response object' do
          resp = CreateNotificationResponse.decode(response.body)
          expect(resp).to be_success
        end
      end

      context 'when the creation fails' do
        let(:expected_failure_reason) { CreateNotificationFailureReason::UNKNOWN_NOTIFICATION_TYPE }

        before do
          failed_context = double('Context', success?: false, failure?: true, failure_reason: expected_failure_reason)
          allow(CreateNotification).to receive(:call).and_return(failed_context)

          post notifications_path, create_notification_request.encode, headers
        end

        it 'fails with status code 403' do
          expect(response.code).to eq '403'
        end

        it 'includes the correct failure reason in the response' do
          resp = CreateNotificationResponse.decode(response.body)
          expect(resp.failure_reason).to eq(expected_failure_reason)
        end
      end
    end

  end
end
