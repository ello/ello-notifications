class AddSnsApplicationIdToDeviceSubscriptions < ActiveRecord::Migration
  def change
    add_reference :device_subscriptions, :sns_application, index: true
  end
end
