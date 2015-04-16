FactoryGirl.define do
  factory :device_subscription do
    bundle_id 'co.ello.ello'
    endpoint_arn 'arn::some-string'
    logged_in_user_id 1234
    enabled 'true'

    trait :apns do
      platform { DeviceSubscription::PLATFORM_APNS }
      platform_device_identifier 'a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4a1b2c3d4'
    end
  end
end
