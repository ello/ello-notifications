class RemoveBundleIdFromDeviceSubscriptions < ActiveRecord::Migration
  def change
    remove_column :device_subscriptions, :bundle_id
  end
end
