class HandleStreamEvent
  include Interactor
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def call
    send(context.kind) if respond_to?(context.kind, true)
  end

  private

  def user_was_created
    create_or_update_user
    subscribe_all_user_devices if wants_push_announcements?
  end

  def user_was_deleted
    User.where(id: user_id).destroy_all
    unsubscribe_all_user_devices
  end

  def user_changed_subscription_preferences
    create_or_update_user
    if wants_push_announcements?
      subscribe_all_user_devices
    else
      unsubscribe_all_user_devices
    end
  end

  def wants_push_announcements?
    wants = (context[:record]['push_notification_preferences'] || {})['announcements']
    wants.nil? ? true : wants
  end

  def device_subscriptions
    @subs ||= DeviceSubscription.enabled.where(logged_in_user_id: user_id)
  end

  def create_or_update_user
    with_retries(max_tries: 5, rescue: ActiveRecord::RecordNotUnique) do
      User.where(id: user_id).first_or_initialize.update(
        notify_of_announcements: wants_push_announcements?
      )
      Rails.logger.debug("Updated user #{user_id} preferences")
    end
  end

  def subscribe_all_user_devices
    device_subscriptions.each do |device|
      if device.supports_announcements? && !device.announcement_subscription_arn
        sub = SnsService.subscribe_to_announcements(device.endpoint_arn)
        device.update(announcement_subscription_arn: sub.arn)
        Rails.logger.debug("Subscribed arn #{sub.arn} to announcements")
      end
    end
  end

  def unsubscribe_all_user_devices
    device_subscriptions.each do |device|
      subscription_arn = device.announcement_subscription_arn
      if subscription_arn
        SnsService.unsubscribe_from_topic(subscription_arn)
        device.update(announcement_subscription_arn: nil)
      end
      Rails.logger.debug("Unsubscribed arn #{subscription_arn} to announcements")
    end
  end

  def user_id
    context[:record]['id']
  end

  add_transaction_tracer :user_was_created, category: :task
  add_transaction_tracer :user_was_deleted, category: :task
  add_transaction_tracer :user_changed_subscription_preferences, category: :task
end
