module NotificationFactory
  def self.build_from_activity(*args)
    ActivityNotification.build(*args)
  end

  private


  class ActivityNotification
    def self.build(activity, destination_user_id)
      new(activity, destination_user_id).build
    end

    def initialize(activity, destination_user_id)
      @activity, @destination_user_id = activity.with_indifferent_access, destination_user_id
    end

    def build
      notification = Notification.new({
        metadata: common_metadata
      })

      builder_method = :"process_#{activity[:kind]}_activity"
      send(builder_method, notification)

      notification
    end

    private

    attr_reader :activity,
      :destination_user_id

    def common_metadata
      {
        destination_user_id: destination_user_id,
        type: activity[:kind],
        origin_user_id: activity[:originating_user_id],
        origin_username: activity[:originating_username]
      }
    end

    def process_repost_activity(notification)
      notification.title = 'New Repost'
      notification.body = "#{activity[:subject][:author][:username]} has reposted one of your posts"
      notification.metadata[:application_target] = "posts/#{activity[:subject][:id]}"
    end

    def process_comment_activity(notification)
      notification.title = 'New Comment'
      notification.body = "#{activity[:subject][:author][:username]} commented on your post"
      notification.metadata[:application_target] = "posts/#{activity[:subject][:parent_post_id]}/comments/#{activity[:subject][:id]}"
    end

    def process_post_mention_activity(notification)
      notification.title = 'New Post Mention'
      notification.body = "#{activity[:subject][:author][:username]} mentioned you in a post"
      notification.metadata[:application_target] = "posts/#{activity[:subject][:id]}"
    end

    def process_comment_mention_activity(notification)
      notification.title = 'New Comment Mention'
      notification.body = "#{activity[:subject][:author][:username]} mentioned you in a comment"
      notification.metadata[:application_target] = "posts/#{activity[:subject][:parent_post_id]}/comments/#{activity[:subject][:id]}"
    end

    def process_followership_activity(notification)
      notification.title = 'New Follower'
      notification.body = "#{activity[:subject][:username]} is now following you"
      notification.metadata[:application_target] = "users/#{activity[:subject][:id]}"
    end

    def process_invite_redemption_activity(notification)
      notification.title = 'New Friends on Ello'
      notification.body = "#{activity[:subject][:username]} has accepted your invitation to join Ello"
      notification.metadata[:application_target] = "users/#{activity[:subject][:id]}"
    end
  end
end
