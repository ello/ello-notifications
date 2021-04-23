# frozen_string_literal: true

class DeleteDeviceSubscription
  include Interactor

  def call
    case request.platform
    when ElloProtobufs::NotificationPlatform::APNS
      delete_apns_subscription
    when ElloProtobufs::NotificationPlatform::GCM
      delete_gcm_subscription
    else
      fail_as_unknown
    end
  end

  private

  def request
    context[:request]
  end

  def delete_apns_subscription
    result = APNS::DeleteSubscription.call({
                                             platform_device_identifier: request.platform_device_identifier,
                                             bundle_identifier: request.bundle_identifier,
                                             logged_in_user_id: request.logged_in_user_id,
                                             marketing_version: request.marketing_version,
                                             build_version: request.build_version
                                           })

    context.fail!(message: result.message, failure_reason: result.failure_reason) if result.failure?
  end

  def delete_gcm_subscription
    result = GCM::DeleteSubscription.call({
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
