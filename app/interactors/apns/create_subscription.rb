class APNS::CreateSubscription

  include Interactor
  include Concerns::DeviceSubscriptionFocused

  def call
    with_retries(max_tries: 5, rescue: ActiveRecord::RecordNotUnique) do
      if subscription = find_subscription_from_context
        update_logged_in_user(subscription) if logged_in_user_has_changed?(subscription)
        update_app_versions(subscription) if app_versions_have_changed?(subscription)
        enable_subscription(subscription) if subscription.disabled?
        ApnsSubscriptionMetric.track_creation_success('reused')
      else
        subscription = build_subscription_from_context
        subscription.endpoint_arn = SnsService.create_subscription_endpoint(subscription)
        subscription.save
        context[:subscription] = subscription
        ApnsSubscriptionMetric.track_creation_success('new')
      end
    end
  rescue SnsService::ServiceError => e
    ApnsSubscriptionMetric.track_creation_failure
    context.fail!(message: e.message)
  end

  private

  def platform
    SnsApplication::PLATFORM_APNS
  end

  def logged_in_user_has_changed?(subscription)
    subscription.logged_in_user_id != context[:logged_in_user_id].to_i
  end

  def app_versions_have_changed?(subscription)
    subscription.build_version != context[:build_version] ||
      subscription.marketing_version != context[:marketing_version]
  end

  def update_logged_in_user(subscription)
    subscription.update_attribute(:logged_in_user_id, context[:logged_in_user_id])
  end

  def update_app_versions(subscription)
    subscription.update_attributes(build_version: context[:build_version],
                                   marketing_version: context[:marketing_version])
  end

  def enable_subscription(subscription)
    SnsService.enable_subscription_endpoint(subscription)
    subscription.update_attribute(:enabled, true)
  end
end
