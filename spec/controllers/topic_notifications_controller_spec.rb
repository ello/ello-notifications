require 'rails_helper'

describe TopicNotificationsController, type: :request do
  let(:valid_headers) do
    {
      'CONTENT_TYPE' => 'application/octet-stream',
      'ACCEPT' => 'application/octet-stream'
    }.merge(basic_auth_env)
  end

  describe 'POST #create' do
    context 'with default content-type' do
      it 'fails with status code 406' do
        post create_topic_notification_path

        expect(response.code).to eq '406'
      end
    end

    context 'using binary content-type' do
      let(:create_topic_notification_request) do
        ElloProtobufs::NotificationService::CreateTopicNotificationRequest.new(
          topic: ElloProtobufs::TopicType::ANNOUNCEMENT_TOPIC,
          announcement: create(:protobuf_announcement)
        )
      end

      context 'when the creation succeeds' do
        before do
          successful_context = build_successful_context
          allow(CreateTopicNotification).to receive(:call).and_return(successful_context)

          post create_topic_notification_path, create_topic_notification_request.encode, valid_headers
        end

        it 'passes the required params and request body to the interactor' do
          expect(CreateTopicNotification).to have_received(:call).with(
            request: create_topic_notification_request
          )
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
        let(:expected_failure_reason) { ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_TOPIC_TYPE }

        before do
          failed_context = build_failed_context(failure_reason: expected_failure_reason)
          allow(CreateTopicNotification).to receive(:call).and_return(failed_context)

          post create_topic_notification_path, create_topic_notification_request.encode, valid_headers
        end

        it 'succeeds with status code 200' do
          expect(response.code).to eq '200'
        end

        it 'includes the correct failure reason in the response' do
          resp = ElloProtobufs::NotificationService::ServiceResponse.decode(response.body)
          expect(resp.failure_reason).to eq(expected_failure_reason)
        end
      end
    end

  end
end
