class AddMarketingVersionToDeviceSubscriptions < ActiveRecord::Migration
  def change
    add_column :device_subscriptions, :marketing_version, :string
  end
end
