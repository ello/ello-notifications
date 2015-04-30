class APNS::CreateSubscription
  include Interactor
  include Concerns::DeviceSubscriptionFocused

  def call
    if subscription = find_subscription_from_context
      if logged_in_user_has_changed?(subscription)
        update_logged_in_user(subscription)
      end
      if subscription.disabled?
        enable_subscription(subscription)
      end
    else
      begin
        subscription = build_subscription_from_context
        subscription.endpoint_arn = SnsEndpointService.create_subscription_endpoint(subscription)
        subscription.save
        context[:subscription] = subscription
      rescue SnsEndpointService::ServiceError => e
        context.fail!(message: e.message)
      end
    end
  end

  private

  def platform
    SnsApplication::PLATFORM_APNS
  end

  def logged_in_user_has_changed?(subscription)
    subscription.logged_in_user_id != context[:logged_in_user_id].to_i
  end

  def update_logged_in_user(subscription)
    subscription.update_attribute(:logged_in_user_id, context[:logged_in_user_id])
  end

  def enable_subscription(subscription)
    subscription.update_attribute(:enabled, true)
  end
end
