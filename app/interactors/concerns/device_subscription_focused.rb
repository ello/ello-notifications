# frozen_string_literal: true

module Concerns::DeviceSubscriptionFocused

  extend ActiveSupport::Concern

  included do
    before do
      context.fail!(message: "Unknown bundle_identifier: #{context[:bundle_identifier]}") unless bundle_identifier_registered?
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
    DeviceSubscription.where(lookup_params).first
  end

  def subscription_params
    lookup_params.merge(logged_in_user_id: context[:logged_in_user_id],
                        build_version: context[:build_version],
                        marketing_version: context[:marketing_version])
  end

  def lookup_params
    {
      sns_application: sns_application,
      platform_device_identifier: context[:platform_device_identifier]
    }
  end
end
