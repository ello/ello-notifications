# frozen_string_literal: true

class User < ActiveRecord::Base

  def increment_notification_count
    self.notification_count += 1
    save
  end

  def reset_notification_count
    self.notification_count = 0
    save
  end

end
