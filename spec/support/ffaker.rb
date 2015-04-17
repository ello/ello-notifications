class FFaker::Ello
  # 64 hexadecimal characters
  def self.ios_device_token
    chars = ('a'..'f').to_a + (0..9).to_a
    64.times.map { chars.sample }.join
  end

  def self.bundle_identifier
    "co.ello.ello#{Random.rand(1000)}"
  end
end
