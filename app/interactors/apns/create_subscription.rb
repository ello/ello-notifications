class APNS::CreateSubscription
  include Interactor

  def call
    if bundle_identifier_registered?
      if existing_subscription = find_subscription_from_context
        if logged_in_user_has_changed?(existing_subscription)
          update_logged_in_user(existing_subscription)
        end
        if existing_subscription.disabled?
          enable_subscription(existing_subscription)
        end
      else
        new_subscription = build_subscription_from_context
        if new_subscription.creatable_on_sns?
          new_subscription.endpoint_arn = create_on_sns(new_subscription)
          new_subscription.save
          context[:subscription] = new_subscription
        else
          failure_message = "Cannot create device subscription: " + new_subscription.errors.full_messages.first
          context.fail!(message: failure_message)
        end
      end
    else
      context.fail!(message: "Unknown bundle_identifier: #{context[:bundle_identifier]}")
    end
  end

  def self.register_bundles(bundles)
    @@bundle_xref_table = bundles
  end

  private

  def bundle_identifier_registered?
    sns_application.present?
  end

  def sns_application
    SnsApplication.where({
      platform: SnsApplication::PLATFORM_APNS,
      bundle_identifier: context[:bundle_identifier]
    }).first
  end

  def logged_in_user_has_changed?(subscription)
    subscription.logged_in_user_id != context[:current_user_id].to_i
  end

  def update_logged_in_user(subscription)
    subscription.update_attribute(:logged_in_user_id, context[:current_user_id])
  end

  def enable_subscription(subscription)
    subscription.update_attribute(:enabled, true)
  end

  def create_on_sns(subscription)
    sns = Aws::SNS::Client.new
    resp = sns.create_platform_endpoint(
      platform_application_arn: subscription.sns_application.application_arn,
      token: subscription.platform_device_identifier,
      attributes: { 'Enabled' => 'true' }
    )
    resp.endpoint_arn
  rescue Aws::Errors::ServiceError => e
    context.fail!(message: e.message)
  end

  def build_subscription_from_context
    DeviceSubscription.new(device_params)
  end

  def find_subscription_from_context
    find_params = device_params.reject { |key,_| key == :logged_in_user_id }
    DeviceSubscription.where(find_params).first
  end

  def device_params
    {
      logged_in_user_id: context[:current_user_id],
      sns_application: sns_application,
      platform_device_identifier: context[:platform_device_identifier],
    }
  end
end
