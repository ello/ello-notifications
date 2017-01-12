class CreateDeviceSubscription
  include Interactor

  def call
    case request.platform
    when ElloProtobufs::NotificationPlatform::APNS
      create_apns_subscription
    when ElloProtobufs::NotificationPlatform::GCM
      create_gcm_subscription
    else
      fail_as_unknown
    end
  end

  private

  def request
    context[:request]
  end

  def create_apns_subscription
    result = APNS::CreateSubscription.call({
      platform_device_identifier: request.platform_device_identifier,
      bundle_identifier: request.bundle_identifier,
      logged_in_user_id: request.logged_in_user_id,
      marketing_version: request.marketing_version,
      build_version: request.build_version
    })

    subscribe_to_announcements(result.subscription) unless result.failure?

    context.fail!(message: result.message, failure_reason: result.failure_reason) if result.failure?
  end

  def create_gcm_subscription
    result = GCM::CreateSubscription.call({
      platform_device_identifier: request.platform_device_identifier,
      bundle_identifier: request.bundle_identifier,
      logged_in_user_id: request.logged_in_user_id,
      marketing_version: request.marketing_version,
      build_version: request.build_version
    })

    subscribe_to_announcements(result.subscription) unless result.failure?

    context.fail!(message: result.message, failure_reason: result.failure_reason) if result.failure?
  end

  def fail_as_unknown
    reason = ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_NOTIFICATION_PLATFORM
    context.fail!(failure_reason: reason)
  end

  def subscribe_to_announcements(device_sub)
    user = User.where(id: device_sub.logged_in_user_id).first_or_create
    if user.notify_of_announcements && device_sub.supports_announcements?
      sub = SnsService.subscribe_to_announcements(device_sub.endpoint_arn)
      device_sub.update(announcement_subscription_arn: sub.arn)
    end
  end
end
