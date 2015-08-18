class User < ActiveRecord::Base

  def increment_notification_count
    self.notification_count += 1
    self.save
  end

  def reset_notification_count
    self.notification_count = 0
    self.save
  end

end
