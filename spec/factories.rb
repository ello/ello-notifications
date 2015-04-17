FactoryGirl.define do
  factory :device_subscription do
    bundle_id 'co.ello.ello'
    endpoint_arn 'arn::some-string'
    sequence(:logged_in_user_id)
    enabled 'true'

    trait :apns do
      platform { DeviceSubscription::PLATFORM_APNS }
      platform_device_identifier { FFaker::Ello.ios_device_token }
    end
  end
end
