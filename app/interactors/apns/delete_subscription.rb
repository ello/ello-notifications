# frozen_string_literal: true

class APNS::DeleteSubscription
  include Interactor
  include Concerns::DeviceSubscriptionFocused

  def call
    if (subscription = find_subscription_from_context)
      begin
        SnsService.delete_subscription_endpoint(subscription)
        subscription.destroy_and_unsubscribe
        ApnsSubscriptionMetric.track_deletion_success
      rescue SnsService::ServiceError => e
        ApnsSubscriptionMetric.track_deletion_failure
        context.fail!(message: e.message)
      end
    else
      context[:message] = 'Subscription could not be found with the input parameters'
    end
  end

  private

  def platform
    SnsApplication::PLATFORM_APNS
  end
end
