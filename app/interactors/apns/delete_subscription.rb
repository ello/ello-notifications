class APNS::DeleteSubscription
  include Interactor
  include Concerns::DeviceSubscriptionFocused

  def call
    if existing_subscription = find_subscription_from_context
      delete_from_sns(existing_subscription)
      existing_subscription.destroy
    else
      context[:message] = 'Subscription could not be found with the input paramaters'
    end
  end

  private

  def platform
    SnsApplication::PLATFORM_APNS
  end

  def delete_from_sns(subscription)
    sns = Aws::SNS::Client.new
    sns.delete_endpoint(
      endpoint_arn: subscription.endpoint_arn
    )
  rescue Aws::Errors::ServiceError => e
    context.fail!(message: e.message)
  end
end
