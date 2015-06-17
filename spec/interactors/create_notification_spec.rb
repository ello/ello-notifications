require 'rails_helper'

describe CreateNotification do

  context 'when called with the required parameters' do
    before do
      # short-hand aliases for test readability purposes
      stub_const('ServiceFailureReason', ElloProtobufs::NotificationService::ServiceFailureReason)
      stub_const('CreateNotificationRequest', ElloProtobufs::NotificationService::CreateNotificationRequest)
      stub_const('NotificationType', ElloProtobufs::NotificationType)
    end

    before { allow(APNS::DeliverNotification).to receive(:call) }

    let(:user_id) { 1234 }
    let(:request) do
      CreateNotificationRequest.new(type: notification_type,
                                    destination_user_id: user_id)
    end

    let(:notification_type) { NotificationType::REPOST }

    def call_interactor
      described_class.call(request: request)
    end

    context 'when the notification type is unknown' do
      let(:notification_type) { NotificationType::UNSPECIFIED_TYPE }

      it 'fails the context with an error reason' do
        result = call_interactor
        expect(result).to_not be_success
        expect(result.failure_reason).to eq(ServiceFailureReason::UNKNOWN_NOTIFICATION_TYPE)
      end
    end

    context 'when the destination user does not have any subscriptions' do
      it 'does not deliver any notifications' do
        some_other_user_id = 5678
        create(:device_subscription, :apns, logged_in_user_id: some_other_user_id)

        result = call_interactor
        expect(APNS::DeliverNotification).to_not have_received(:call)
        expect(result).to be_success
      end
    end

    context 'when the destination user has a subscription to an unknown platform' do
      it 'does not fail, allowing for delivery to other platforms' do
        request.post = create(:protobuf_post, :repost)
        application = build(:sns_application, platform: 'unknown')
        application.save(validate: false)
        create(:device_subscription, logged_in_user_id: user_id, sns_application: application)

        result = call_interactor
        expect(result).to be_success
      end
    end

    context 'when the destination user only has a disabled subscription' do
      it 'does not deliver any notifications' do
        create(:device_subscription, :apns, :disabled, logged_in_user_id: user_id)

        result = call_interactor
        expect(APNS::DeliverNotification).to_not have_received(:call)
        expect(result).to be_success
      end
    end

    context 'when the destination user has an enabled subscription' do
      before { create(:device_subscription, :apns, logged_in_user_id: user_id) }

      describe 'protobuf decoding' do
        ['REPOST', 'POST_MENTION'].each do |post_related_type|
          context "when the notification is a #{post_related_type}" do
            let(:notification_type) { Object.const_get("NotificationType::#{post_related_type}") }
            let(:post) { create(:protobuf_post) }

            before { request.post = post }

            it 'plucks the post from the request and passes it into the notification factory' do
              expect(Notification::Factory).to receive(:build)
                .with(notification_type, user_id, post)
              call_interactor
            end
          end
        end

        ['POST_COMMENT', 'COMMENT_MENTION', 'REPOST_COMMENT_TO_REPOST_AUTHOR',
         'REPOST_COMMENT_TO_ORIGINAL_AUTHOR'].each do |comment_related_type|
          context "when the notification is a #{comment_related_type}" do
            let(:notification_type) { Object.const_get("NotificationType::#{comment_related_type}") }
            let(:comment) { create(:protobuf_comment) }

            before { request.comment = comment }

            it 'plucks the comment from the request and passes it into the notification factory' do
              expect(Notification::Factory).to receive(:build)
                .with(notification_type, user_id, comment)
              call_interactor
            end
          end
        end

        ['FOLLOWER', 'INVITE_REDEMPTION'].each do |user_related_type|
          context "when the notification is a #{user_related_type}" do
            let(:notification_type) { Object.const_get("NotificationType::#{user_related_type}") }
            let(:user) { create(:protobuf_user) }

            before { request.user = user }

            it 'plucks the user from the request and passes it into the notification factory' do
              expect(Notification::Factory).to receive(:build)
                .with(notification_type, user_id, user)
              call_interactor
            end

          end
        end
      end

      it 'delivers the notification to the subscription' do
        notification = instance_double('Notification')
        allow(Notification::Factory).to receive(:build).and_return(notification)

        call_interactor
        expect(APNS::DeliverNotification).to have_received(:call).with({
          notification: notification,
          endpoint_arn: DeviceSubscription.last.endpoint_arn
        })
      end
    end

    context 'when the destination user has multiple enabled subscriptions' do
      let!(:user_subscriptions) { create_list(:device_subscription, 2, :apns, logged_in_user_id: user_id) }
      before { request.post = create(:protobuf_post, :repost) }

      it 'delivers the notification to all subscriptions' do
        call_interactor
        user_subscriptions.each do |sub|
          expect(APNS::DeliverNotification).to have_received(:call).
            with(hash_including(endpoint_arn: sub.endpoint_arn))
        end
      end

      context 'when the first subscription delivery fails' do
        let(:failing_subscription) { user_subscriptions.first }
        let(:failed_context) do
          build_failed_context(endpoint_arn: failing_subscription.endpoint_arn,
                               notification: instance_double(Notification),
                               message: 'some error')
        end

        before do
          allow(APNS::DeliverNotification).to receive(:call).
            and_return(failed_context, build_successful_context)
        end

        it 'logs the failure' do
          error_message = "Failed to send notification to ARN: #{failed_context.endpoint_arn}.  Error received: #{failed_context.message}.  Given request: #{request}"
          expect(Rails.logger).to receive(:warn).with(error_message)

          call_interactor
        end

        it 'disables the subscription locally' do
          expect {
            call_interactor
          }.to change { failing_subscription.reload.enabled }.to(false)
        end

        it 'continues sending after the first failure' do
          call_interactor

          expect(APNS::DeliverNotification).to have_received(:call).twice
        end

        it 'does not fail externally when a notification fails to deliver' do
          result = call_interactor
          expect(result).to be_success
        end
      end
    end

  end

end
