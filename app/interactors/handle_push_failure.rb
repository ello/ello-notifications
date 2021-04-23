# frozen_string_literal: true

class HandlePushFailure
  include SuckerPunch::Job

  def perform(token)
    ActiveRecord::Base.connection_pool.with_connection do
      if (subscription = DeviceSubscription.find_by(platform_device_identifier: token))
        subscription.destroy_and_unsubscribe
      end
    end
  end
end
