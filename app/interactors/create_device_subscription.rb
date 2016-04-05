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

    context.fail!(message: result.message, failure_reason: result.failure_reason) if result.failure?
  end

  def fail_as_unknown
    reason = ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_NOTIFICATION_PLATFORM
    context.fail!(failure_reason: reason)
  end
end
