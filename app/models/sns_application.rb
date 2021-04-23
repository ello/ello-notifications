# frozen_string_literal: true

class SnsApplication < ActiveRecord::Base
  PLATFORM_APNS = 'APNS'
  PLATFORM_GCM = 'GCM'

  has_many :device_subscriptions

  validates :bundle_identifier, format: { with: /\A([^.]{2,}\.){2,}[^.]{2,}\z/, message: 'not a valid bundle id' }
  validates :bundle_identifier, uniqueness: { scope: :platform }
  validates :platform, inclusion: { in: [PLATFORM_APNS, PLATFORM_GCM] }
end
