class Notification
  include ActiveModel::Model

  REGISTERED_TYPES = [
    'comment_mention',
    'follower',
    'invite_redemption',
    'post_comment',
    'post_mention',
    'repost',
  ].freeze

  attr_accessor :title,
                :body,
                :metadata

  def metadata
    @metadata ||= {}
  end

  def self.type_registered?(type)
    REGISTERED_TYPES.include?(type)
  end

  class Factory

    def self.build(*args)
      new(*args).build
    end

    def initialize(notification_type, destination_user_id, related_object=nil)
      @type, @destination_user_id, @related_object = notification_type, destination_user_id, related_object
    end

    def build
      notification = Notification.new({
        metadata: common_metadata
      })

      builder_method = :"build_as_#{@type}_notification"
      send(builder_method, notification)

      notification
    end

    private

    attr_reader :related_object

    def common_metadata
      {
        destination_user_id: @destination_user_id,
        type: @type
      }
    end

    def build_as_repost_notification(notification)
      notification.title = 'New Repost'
      notification.body = "#{related_object.author.username} has reposted one of your posts"
      notification.metadata[:application_target] = "posts/#{related_object.id}"
    end

    def build_as_post_comment_notification(notification)
      notification.title = 'New Comment'
      notification.body = "#{related_object.author.username} commented on your post"
      notification.metadata[:application_target] = "posts/#{related_object.parent_post_id}/comments/#{related_object.id}"
    end

    def build_as_post_mention_notification(notification)
      notification.title = 'New Post Mention'
      notification.body = "#{related_object.author.username} mentioned you in a post"
      notification.metadata[:application_target] = "posts/#{related_object.id}"
    end

    def build_as_comment_mention_notification(notification)
      notification.title = 'New Comment Mention'
      notification.body = "#{related_object.author.username} mentioned you in a comment"
      notification.metadata[:application_target] = "posts/#{related_object.parent_post_id}/comments/#{related_object.id}"
    end

    def build_as_follower_notification(notification)
      notification.title = 'New Follower'
      notification.body = "#{related_object.username} is now following you"
      notification.metadata[:application_target] = "users/#{related_object.id}"
    end

    def build_as_invite_redemption_notification(notification)
      notification.title = 'New Friends on Ello'
      notification.body = "#{related_object.username} has accepted your invitation to join Ello"
      notification.metadata[:application_target] = "users/#{related_object.id}"
    end
  end

end
