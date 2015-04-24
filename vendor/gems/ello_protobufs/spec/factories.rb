require 'securerandom'
require 'faker'

FactoryGirl.define do
  factory :protobuf_user, class: ElloProtobufs::User do
    skip_create
    sequence(:id)
    username { Faker::Internet.user_name(name, ['_']) }
    href { "http://ello.co/#{username}" }
    name { Faker::Name.name }
    created_at { Time.now.to_i }
    updated_at { Time.now.to_i }
  end

  factory :protobuf_post, class: ElloProtobufs::Post do
    skip_create
    sequence(:id)
    token { SecureRandom.uuid }
    href { "http://ello.co/#{author.username}/#{token}" }
    author { create(:protobuf_user) }
    created_at { Time.now.to_i }
    updated_at { Time.now.to_i }

    trait :repost do
      reposted_source_id { generate(:id) }
    end

    trait :reposted_repost do
      reposted_source_id { generate(:id) }
      reposted_via_id { generate(:id) }
    end
  end
end
