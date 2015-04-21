module NotificationFactory
  def self.build_from_activity(activity)
    ActivityBuilder.new(activity).build
  end

  private


  class ActivityBuilder
    def initialize(activity)
      @activity = activity
    end

    def build
      Notification.new
    end

    private

    def repost_activity
    end
    def comment_activity
    end
    def mention_activity
    end
    def followership_activity
    end
    def invite_redemption_activity
    end
  end
end
