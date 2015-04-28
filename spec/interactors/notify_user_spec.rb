require 'rails_helper'

describe NotifyUser do

  context 'when called with the required parameters' do
    before { allow(APNS::DeliverNotification).to receive(:call) }

    let(:user_id) { '1234' }
    let(:request_body) { create(:protobuf_post).encode }
    let(:notification_type) { 'repost' }

    def call_interactor
      described_class.call(destination_user_id: user_id,
                           notification_type: notification_type,
                           request_body: request_body)
    end

    context 'when the notification type is unknown' do
      let(:notification_type) { 'bad_type' }

      it 'fails the context with an error message' do
        result = call_interactor
        expect(result).to_not be_success
        expect(result.message).to eq 'Unknown notification type: bad_type'
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
        ['repost', 'post_mention'].each do |post_related_type|
          context "when the notification is a #{post_related_type}" do
            let(:notification_type) { post_related_type }

            context 'when the request body is a string' do
              let(:request_body) { create(:protobuf_post).encode }
              it 'decodes the request body as a post and passes it into the notification factory' do
                post = instance_spy(ElloProtobufs::Post)
                expect(ElloProtobufs::Post).to receive(:decode).with(request_body).and_return(post)
                expect(Notification::Factory).to receive(:build)
                  .with(post_related_type, user_id, post)
                call_interactor
              end
            end

            context 'when the request body is a StringIO' do
              let(:request_body) do
                stream = StringIO.new
                create(:protobuf_post).encode_to(stream)
                stream
              end
              it 'decodes the request body as a post and passes it into the notification factory' do
                post = instance_spy(ElloProtobufs::Post)
                expect(ElloProtobufs::Post).to receive(:decode_from).with(request_body).and_return(post)
                expect(Notification::Factory).to receive(:build)
                  .with(post_related_type, user_id, post)
                call_interactor
              end
            end
          end
        end

        ['post_comment', 'comment_mention'].each do |comment_related_type|
          context "when the notification is a #{comment_related_type}" do
            let(:notification_type) { comment_related_type }

            context 'when the request body is a string' do
              let(:request_body) { create(:protobuf_post).encode }
              it 'decodes the request body as a comment and passes it into the notification factory' do
                comment = instance_spy(ElloProtobufs::Comment)
                expect(ElloProtobufs::Comment).to receive(:decode).with(request_body).and_return(comment)
                expect(Notification::Factory).to receive(:build)
                  .with(comment_related_type, user_id, comment)
                call_interactor
              end
            end

            context 'when the request body is a StringIO' do
              let(:request_body) do
                stream = StringIO.new
                create(:protobuf_comment).encode_to(stream)
                stream
              end
              it 'decodes the request body as a comment and passes it into the notification factory' do
                comment = instance_spy(ElloProtobufs::Comment)
                expect(ElloProtobufs::Comment).to receive(:decode_from).with(request_body).and_return(comment)
                expect(Notification::Factory).to receive(:build)
                  .with(comment_related_type, user_id, comment)
                call_interactor
              end
            end
          end
        end

        ['follower', 'invite_redemption'].each do |user_related_type|
          context "when the notification is a #{user_related_type}" do
            let(:notification_type) { user_related_type }

            context 'when the request body is a string' do
              let(:request_body) { create(:protobuf_user).encode }
              it 'decodes the request body as a user and passes it into the notification factory' do
                user = instance_spy(ElloProtobufs::User)
                expect(ElloProtobufs::User).to receive(:decode).with(request_body).and_return(user)
                expect(Notification::Factory).to receive(:build)
                  .with(user_related_type, user_id, user)
                call_interactor
              end
            end

            context 'when the request body is a StringIO' do
              let(:request_body) do
                stream = StringIO.new
                create(:protobuf_user).encode_to(stream)
                stream
              end
              it 'decodes the request body as a user and passes it into the notification factory' do
                user = instance_spy(ElloProtobufs::User)
                expect(ElloProtobufs::User).to receive(:decode_from).with(request_body).and_return(user)
                expect(Notification::Factory).to receive(:build)
                  .with(user_related_type, user_id, user)
                call_interactor
              end
            end

          end
        end
      end

      it 'passes the factory built notification to the associated delivery interactor' do
        notification = instance_double('Notification')
        allow(Notification::Factory).to receive(:build).and_return(notification)

        call_interactor
        expect(APNS::DeliverNotification).to have_received(:call).
          with(hash_including(notification: notification))
      end

      it 'delivers the notification to the subscription' do
        call_interactor
        expect(APNS::DeliverNotification).to have_received(:call).with({
          notification: kind_of(Notification),
          endpoint_arn: DeviceSubscription.last.endpoint_arn
        })
      end
    end

    context 'when the destination user has multiple enabled subscriptions' do
      it 'delivers the notification to all subscriptions' do
        user_subscriptions = create_list(:device_subscription, 2, :apns, logged_in_user_id: user_id)

        call_interactor
        user_subscriptions.each do |sub|
          expect(APNS::DeliverNotification).to have_received(:call).
            with(hash_including(endpoint_arn: sub.endpoint_arn))
        end
      end
    end

  end

end
