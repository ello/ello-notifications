class DeviceSubscription < ActiveRecord::Base
  PLATFORM_APNS = 'APNS'.freeze

  validates_presence_of :bundle_id,
    :endpoint_arn,
    :logged_in_user_id,
    :platform,
    :platform_device_identifier

  validates_inclusion_of :platform, in: [PLATFORM_APNS]

  validates_format_of :bundle_id, with: /\A([^\.]{2,}\.){2,}[^\.]{2,}\z/, message: 'not a valid bundle id'
  validates_format_of :platform_device_identifier, with: /\A[a-z0-9]{64}\z/, message: 'not a valid device token'

  after_initialize :default_to_enabled

  def apns?
    platform == PLATFORM_APNS
  end

  def creatable_on_sns?
    return false if endpoint_arn.present?

    valid? # run validations
    errors.keys == [:endpoint_arn] # ensure valid? except for endpoint_arn
  end

  private

  def default_to_enabled
    self.enabled = true if self.enabled.nil?
  end

end
