class AddIndexOnDeviceSubscriptionsLoggedInUserId < ActiveRecord::Migration
  disable_ddl_transaction!
  def change
    add_index :device_subscriptions, :logged_in_user_id, algorithm: :concurrently
  end
end
