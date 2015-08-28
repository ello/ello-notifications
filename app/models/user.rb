class User < ActiveRecord::Base

  def increment_notification_count
    # TODO fix this soon (it should increment by one)
    self.notification_count = 0
    self.save
  end

  def reset_notification_count
    self.notification_count = 0
    self.save
  end

end
