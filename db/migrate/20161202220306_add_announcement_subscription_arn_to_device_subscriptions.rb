class AddAnnouncementSubscriptionArnToDeviceSubscriptions < ActiveRecord::Migration
  def change
    add_column :device_subscriptions, :announcement_subscription_arn, :string
  end
end
