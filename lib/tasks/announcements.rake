namespace :announcments do
  desc 'Subscribes all unsubscribed enabled devices to announcment topic'
  task subscribe_all: :environment do
    User.where(notify_of_announcements: true).find_each do |user|
      DeviceSubscription.enabled.where(logged_in_user_id: user.id, announcement_subscription_arn: nil).each do |device|
        if device.supports_announcements?
          sub = SnsService.subscribe_to_announcements(device.endpoint_arn)
          device.update(announcement_subscription_arn: sub.arn)
        end
      end
    end
  end
end
