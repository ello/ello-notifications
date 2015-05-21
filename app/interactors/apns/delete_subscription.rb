class APNS::DeleteSubscription
  include Interactor
  include Concerns::DeviceSubscriptionFocused

  def call
    if subscription = find_subscription_from_context
      begin
        SnsService.delete_subscription_endpoint(subscription)
        subscription.destroy
      rescue SnsService::ServiceError => e
        context.fail!(message: e.message)
      end
    else
      context[:message] = 'Subscription could not be found with the input paramaters'
    end
  end

  private

  def platform
    SnsApplication::PLATFORM_APNS
  end
end
