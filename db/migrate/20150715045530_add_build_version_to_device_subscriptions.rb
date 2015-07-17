class AddBuildVersionToDeviceSubscriptions < ActiveRecord::Migration
  def change
    add_column :device_subscriptions, :build_version, :string
  end
end
