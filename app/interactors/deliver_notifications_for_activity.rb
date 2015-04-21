class DeliverNotificationsForActivity
  include Interactor

  def call
    if user_subscriptions.any?
      notification = NotificationFactory.build_from_activity(context[:activity])
      user_subscriptions.each do |sub|
        deliver_notification(notification, sub)
      end
    end
  end

  private

  def user_subscriptions
    @subs ||= DeviceSubscription.enabled.where(logged_in_user_id: context[:destination_user_id])
  end

  def deliver_notification(notification, subscription)
    case subscription.platform
    when SnsApplication::PLATFORM_APNS
      APNS::DeliverNotification.call(notification: notification, endpoint_arn: subscription.endpoint_arn)
    end
  end

end
