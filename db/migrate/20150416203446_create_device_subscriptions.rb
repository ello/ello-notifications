class CreateDeviceSubscriptions < ActiveRecord::Migration
  def change
    create_table :device_subscriptions do |t|
      t.string :platform_device_identifier
      t.string :bundle_id
      t.string :endpoint_arn
      t.integer :logged_in_user_id
      t.string :platform
      t.boolean :enabled

      t.timestamps
    end
  end
end
