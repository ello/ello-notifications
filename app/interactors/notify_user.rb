class NotifyUser
  include Interactor

  def call
    if Notification.type_registered?(context[:notification_type])
      if user_subscriptions.any?
        request_object = decode_request_object
        notification = Notification::Factory.build(context[:notification_type],
                                                 context[:destination_user_id],
                                                 request_object)
        user_subscriptions.each do |sub|
          deliver_notification(notification, sub)
        end
      end
    else
      context.fail!(message: "Unknown notification type: #{context[:notification_type]}")
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

  def decode_request_object
    decoder = context[:request_body].instance_of?(StringIO) ? :decode_from : :decode
    case context[:notification_type]
    when 'repost', 'post_mention'
      ElloProtobufs::Post.public_send(decoder, context[:request_body])
    when 'post_comment', 'comment_mention'
      ElloProtobufs::Comment.public_send(decoder, context[:request_body])
    when 'follower', 'invite_redemption'
      ElloProtobufs::User.public_send(decoder, context[:request_body])
    end
  end

end
