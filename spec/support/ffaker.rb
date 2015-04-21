class FFaker::Ello
  # 64 hexadecimal characters
  def self.ios_device_token
    chars = ('a'..'f').to_a + (0..9).to_a
    64.times.map { chars.sample }.join
  end

  def self.sns_apns_endpoint_arn(sandbox:false)
    platform_key = sandbox ? 'APNS_SANDBOX' : 'APNS'
    app_ref_id = Random.rand(1000)
    subscription_ref_id = Random.rand(1000)
    app_name = FFaker::Lorem.words(2).join
    "arn:aws:sns:us-east-1:#{app_ref_id}:endpoint/#{platform_key}/#{app_name}/#{subscription_ref_id}"
  end

  def self.bundle_identifier
    "co.ello.ello#{Random.rand(1000)}"
  end
end
