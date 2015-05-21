class SnsApplication < ActiveRecord::Base
  PLATFORM_APNS = 'APNS'.freeze
  PLATFORM_GCM = 'GCM'.freeze

  has_many :device_subscriptions

  validates_format_of :bundle_identifier, with: /\A([^\.]{2,}\.){2,}[^\.]{2,}\z/, message: 'not a valid bundle id'
  validates_uniqueness_of :bundle_identifier, scope: :platform
  validates_inclusion_of :platform, in: [PLATFORM_APNS, PLATFORM_GCM]
end
