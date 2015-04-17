class DeviceSubscription < ActiveRecord::Base
  belongs_to :sns_application

  validates_presence_of :logged_in_user_id,
    :platform_device_identifier,
    :sns_application

  validates_format_of :platform_device_identifier,
    with: /\A[a-f0-9]{64}\z/, message: 'not a valid device token',
    if: :apns?

  after_initialize :default_to_enabled

  def apns?
    sns_application.try(:platform) == SnsApplication::PLATFORM_APNS
  end

  def disabled?
    !enabled?
  end

  def creatable_on_sns?
    if endpoint_arn.present?
      errors.add(:endpoint_arn, 'SNS endpoint has already been created')
      false
    else
      valid?
    end
  end

  private

  def default_to_enabled
    self.enabled = true if self.enabled.nil?
  end

end
