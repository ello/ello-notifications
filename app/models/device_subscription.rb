class DeviceSubscription < ActiveRecord::Base
  belongs_to :sns_application

  scope :enabled, -> { where(enabled: true) }

  validates_presence_of :logged_in_user_id,
                        :platform_device_identifier,
                        :sns_application

  validates_format_of :platform_device_identifier,
                      with: /\A[a-f0-9]{64}\z/, message: 'not a valid device token',
                      if: :apns?

  after_initialize :default_to_enabled

  delegate :platform, to: :sns_application

  def can_handle_blank_pushes?
    build_version.to_i >= 3216
  end

  def apns?
    sns_application.try(:platform) == SnsApplication::PLATFORM_APNS
  end

  def gcm?
    sns_application.try(:platform) == SnsApplication::PLATFORM_GCM
  end

  def disabled?
    !enabled?
  end

  def disable
    unsubscribe_from_announcments
    update_attribute(:enabled, false)
  end

  def enable
    update_attribute(:enabled, true)
  end

  def destroy_and_unsubscribe
    unsubscribe_from_announcments
    destroy
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

  def unsubscribe_from_announcments
    if announcement_subscription_arn
      SnsService.unsubscribe_from_topic(announcement_subscription_arn)
    end
  end
end
