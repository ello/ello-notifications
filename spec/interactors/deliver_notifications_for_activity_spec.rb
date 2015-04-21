require 'rails_helper'

describe DeliverNotificationsForActivity do

  context 'when called with the required parameters' do
    before { allow(APNS::DeliverNotification).to receive(:call) }

    context 'when the destination user does not have any subscriptions' do
      it 'does not deliver any notifications' do
        user_id = 1234
        some_other_user_id = 5678
        create(:device_subscription, :apns, logged_in_user_id: some_other_user_id)

        described_class.call(destination_user_id: user_id, activity: {})
        expect(APNS::DeliverNotification).to_not have_received(:call)
      end
    end

    context 'when the destination user has a subscription to an unknown platform' do
      it 'does not fail' do
        user_id = 1234
        application = build(:sns_application, platform: 'unknown')
        application.save(validate: false)
        create(:device_subscription, logged_in_user_id: user_id, sns_application: application)

        result = described_class.call(destination_user_id: user_id, activity: {})
        expect(result).to be_success
      end
    end

    context 'when the destination user only has a disabled subscription' do
      it 'does not deliver any notifications' do
        subscription = create(:device_subscription, :apns, :disabled)

        described_class.call(destination_user_id: subscription.logged_in_user_id, activity: {})
        expect(APNS::DeliverNotification).to_not have_received(:call)
      end
    end

    context 'when the destination user has an enabled subscription' do
      it 'delivers the notification to the subscription' do
        user_id = 1234
        subscription = create(:device_subscription, :apns, logged_in_user_id: user_id)

        described_class.call(destination_user_id: user_id, activity: {})
        expect(APNS::DeliverNotification).to have_received(:call).with({
          notification: kind_of(Notification),
          endpoint_arn: subscription.endpoint_arn
        })
      end

      it 'builds the notification using the notification factory' do
        user_id = 1234
        activity = {}
        create(:device_subscription, :apns, logged_in_user_id: user_id)
        allow(NotificationFactory).to receive(:build_from_activity).and_call_original

        described_class.call(destination_user_id: user_id, activity: activity)
        expect(NotificationFactory).to have_received(:build_from_activity).with(activity)
      end

      it 'passes the factory built notification to the associated delivery interactor' do
        user_id = 1234
        activity = {}
        notification = instance_double('Notification')
        create(:device_subscription, :apns, logged_in_user_id: user_id)
        allow(NotificationFactory).to receive(:build_from_activity).and_return(notification)

        described_class.call(destination_user_id: user_id, activity: activity)
        expect(APNS::DeliverNotification).to have_received(:call).
          with(hash_including(notification: notification))
      end
    end

    context 'when the destination user has multiple enabled subscriptions' do
      it 'delivers the notification to all subscriptions' do
        user_id = 1234
        user_subscriptions = create_list(:device_subscription, 2, :apns, logged_in_user_id: user_id)

        described_class.call(destination_user_id: user_id, activity: {})
        user_subscriptions.each do |sub|
          expect(APNS::DeliverNotification).to have_received(:call).
            with(hash_including(endpoint_arn: sub.endpoint_arn))
        end
      end
    end

  end

end
