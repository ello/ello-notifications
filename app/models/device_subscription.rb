# frozen_string_literal: true

class DeviceSubscription < ActiveRecord::Base
  IOS_1_20 = 5557
  belongs_to :sns_application

  scope :enabled, -> { where(enabled: true) }

  validates :logged_in_user_id,
            :platform_device_identifier,
            :sns_application, presence: true

  validates :platform_device_identifier,
            format: { with: /\A[a-f0-9]{64}\z/, message: 'not a valid device token',
                      if: :apns? }

  after_initialize :default_to_enabled

  delegate :platform, to: :sns_application

  def can_handle_blank_pushes?
    build_version.to_i >= 3216
  end

  def supports_announcements?
    gcm? || (build_version && build_version.to_i >= IOS_1_20)
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
    self.enabled = true if enabled.nil?
  end

  def unsubscribe_from_announcments
    SnsService.unsubscribe_from_topic(announcement_subscription_arn) if announcement_subscription_arn
  end
end
