FactoryGirl.define do
  sequence(:unique_id)

  factory :user do
    notification_count 0
  end

  factory :sns_application do
    bundle_identifier { Faker::Ello.bundle_identifier }
    sequence(:application_arn) { |n| "arn:aws:sns:application-string#{n}" }

    trait :apns do
      platform { SnsApplication::PLATFORM_APNS }
    end

    trait :gcm do
      platform { SnsApplication::PLATFORM_GCM }
    end
  end

  factory :device_subscription do
    sns_application
    endpoint_arn { Faker::Ello.sns_apns_endpoint_arn }
    sequence(:logged_in_user_id)
    enabled true
    platform_device_identifier 'someident'

    trait :creatable_on_sns do
      endpoint_arn nil
    end

    trait :apns do
      sns_application { build(:sns_application, :apns) }
      platform_device_identifier { Faker::Ello.ios_device_token }
    end

    trait :disabled do
      enabled false
    end
  end

  factory :notification do
    title { Faker::Lorem.words(2).join(' ') }
    body { Faker::Lorem.sentence }
    badge_count { Random.rand(10) }
    metadata {
      { custom_key: '1' }
    }

    trait :badge_count_only do
      include_alert false
      metadata { {} }
    end
  end
end
