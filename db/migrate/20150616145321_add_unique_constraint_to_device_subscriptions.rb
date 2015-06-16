class AddUniqueConstraintToDeviceSubscriptions < ActiveRecord::Migration
  def change
    add_index :device_subscriptions,
              [:platform_device_identifier, :sns_application_id],
              unique: true,
              name: 'index_device_subscriptions_on_unique_keys'
  end
end
