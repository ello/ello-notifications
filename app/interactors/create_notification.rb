class CreateNotification
  include Interactor

  def call
    if valid_notification_type?
      if user_subscriptions.any?
        related_object = pluck_related_object
        user = User.find_or_create_by(id: context[:request].destination_user_id)

        if context[:request].type == ElloProtobufs::NotificationType::RESET_BADGE_COUNT
          user.reset_notification_count
        else
          user.increment_notification_count
        end

        notification = Notification::Factory.build(context[:request].type,
                                                   user,
                                                   related_object)
        user_subscriptions.each do |sub|
          if should_deliver_notification?(context[:request], notification, sub)
            result = deliver_notification(notification, sub)
            if result && result.failure?
              sub.disable if result.message.match(/Endpoint is disabled/)
              log_failure(result)
            end
          end
        end
      end
    else
      reason = ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_NOTIFICATION_TYPE
      context.fail!(failure_reason: reason,
                    message: "Notification type (#{context[:request].type}) is not handled")
    end
  end

  private

  def valid_notification_type?
    context[:request].type != ElloProtobufs::NotificationType::UNSPECIFIED_TYPE
  end

  def should_deliver_notification?(request, notification, subscription)
    if request.type == ElloProtobufs::NotificationType::RESET_BADGE_COUNT
      subscription.can_handle_blank_pushes?
    else
      true
    end
  end

  def user_subscriptions
    @subs ||= DeviceSubscription.enabled.where(logged_in_user_id: context[:request].destination_user_id)
  end

  def deliver_notification(notification, subscription)
    case subscription.platform
    when SnsApplication::PLATFORM_APNS
      APNS::DeliverNotification.call(notification: notification, endpoint_arn: subscription.endpoint_arn)
    end
  end

  def log_failure(result)
    Rails.logger.warn("Failed to send notification to ARN: #{result.endpoint_arn}.  Error received: #{result.message}.  Given request: #{context[:request]}")
  end

  def pluck_related_object
    case context[:request].type
    when *post_related_types
      context[:request].post
    when *comment_related_types
      context[:request].comment
    when *user_related_types
      context[:request].user
    when *love_related_types
      context[:request].love
    end
  end

  def post_related_types
    [ ElloProtobufs::NotificationType::REPOST, ElloProtobufs::NotificationType::POST_MENTION ]
  end

  def comment_related_types
    [ ElloProtobufs::NotificationType::POST_COMMENT, ElloProtobufs::NotificationType::COMMENT_MENTION,
      ElloProtobufs::NotificationType::REPOST_COMMENT_TO_REPOST_AUTHOR,
      ElloProtobufs::NotificationType::REPOST_COMMENT_TO_ORIGINAL_AUTHOR
    ]
  end

  def love_related_types
    [ ElloProtobufs::NotificationType::POST_LOVE, ElloProtobufs::NotificationType::POST_LOVE,
      ElloProtobufs::NotificationType::REPOST_LOVE_TO_REPOST_AUTHOR,
      ElloProtobufs::NotificationType::REPOST_LOVE_TO_ORIGINAL_AUTHOR
    ]
  end

  def user_related_types
    [ ElloProtobufs::NotificationType::FOLLOWER, ElloProtobufs::NotificationType::INVITE_REDEMPTION ]
  end

end
