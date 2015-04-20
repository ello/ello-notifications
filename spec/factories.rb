FactoryGirl.define do
  factory :sns_application do
    bundle_identifier { FFaker::Ello.bundle_identifier }
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
    endpoint_arn 'arn:aws:sns:endpoint-string'
    sequence(:logged_in_user_id)
    enabled true

    trait :apns do
      sns_application { build(:sns_application, :apns) }
      platform_device_identifier { FFaker::Ello.ios_device_token }
    end

    trait :disabled do
      enabled false
    end
  end

  factory :notification do
    title { FFaker::Lorem.words(2).join(' ') }
    body { FFaker::Lorem.sentence }
    metadata {
      {
        custom_key: '1'
      }
    }
  end
end
