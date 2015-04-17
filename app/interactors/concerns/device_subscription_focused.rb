module Concerns::DeviceSubscriptionFocused
  extend ActiveSupport::Concern

  included do
    before do
      unless bundle_identifier_registered?
        context.fail!(message: "Unknown bundle_identifier: #{context[:bundle_identifier]}")
      end
    end
  end

  protected

  def bundle_identifier_registered?
    sns_application.present?
  end

  def sns_application
    SnsApplication.where({
      platform: platform,
      bundle_identifier: context[:bundle_identifier]
    }).first
  end

  def platform
    raise NotImplementedError, 'Method platform must be implemented'
  end

  def build_subscription_from_context
    DeviceSubscription.new(subscription_params)
  end

  def find_subscription_from_context
    find_params = subscription_params.reject { |key,_| key == :logged_in_user_id }
    DeviceSubscription.where(find_params).first
  end

  def subscription_params
    {
      logged_in_user_id: context[:current_user_id],
      sns_application: sns_application,
      platform_device_identifier: context[:platform_device_identifier],
    }
  end
end
