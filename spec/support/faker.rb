# frozen_string_literal: true

class Faker::Ello
  # 64 hexadecimal characters
  def self.ios_device_token
    chars = ('a'..'f').to_a + (0..9).to_a
    64.times.map { chars.sample }.join
  end

  # 163 hexadecimal characters
  def self.android_registration_id
    chars = ('a'..'f').to_a + (0..9).to_a
    163.times.map { chars.sample }.join
  end

  def self.sns_apns_endpoint_arn(sandbox: false)
    platform_key = sandbox ? 'APNS_SANDBOX' : 'APNS'
    app_ref_id = FactoryGirl.generate(:unique_id)
    subscription_ref_id = FactoryGirl.generate(:unique_id)
    app_name = Faker::Lorem.words(2).join
    "arn:aws:sns:us-east-1:#{app_ref_id}:endpoint/#{platform_key}/#{app_name}/#{subscription_ref_id}"
  end

  def self.sns_gcm_endpoint_arn
    platform_key = 'GCM'
    app_ref_id = FactoryGirl.generate(:unique_id)
    subscription_ref_id = FactoryGirl.generate(:unique_id)
    app_name = Faker::Lorem.words(2).join
    "arn:aws:sns:us-east-1:#{app_ref_id}:endpoint/#{platform_key}/#{app_name}/#{subscription_ref_id}"
  end

  def self.bundle_identifier
    "co.ello.ello#{FactoryGirl.generate(:unique_id)}"
  end
end
