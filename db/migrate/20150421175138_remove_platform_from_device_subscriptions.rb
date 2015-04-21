class RemovePlatformFromDeviceSubscriptions < ActiveRecord::Migration
  def change
    remove_column :device_subscriptions, :platform
  end
end
