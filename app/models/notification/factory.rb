class Notification::Factory
  @@type_decorators = []

  def self.build(*args)
    new(*args).build
  end

  def self.register_type(type, readable_type, &evaluator)
    @@type_decorators << TypeDecorator.new(type, readable_type, evaluator)
  end

  register_type ElloProtobufs::NotificationType::REPOST, 'repost' do |related_object|
    title { 'New Repost' }
    body { "#{related_object.author.username} has reposted one of your posts" }
    application_target { "posts/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::POST_COMMENT, 'post_comment' do |related_object|
    title { 'New Comment' }
    body { "#{related_object.author.username} commented on your post" }
    application_target { "posts/#{related_object.parent_post_id}/comments/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::POST_MENTION, 'post_mention' do |related_object|
    title { 'New Post Mention' }
    body { "#{related_object.author.username} mentioned you in a post" }
    application_target { "posts/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::COMMENT_MENTION, 'comment_mention' do |related_object|
    title { 'New Comment Mention' }
    body { "#{related_object.author.username} mentioned you in a comment" }
    application_target { "posts/#{related_object.parent_post_id}/comments/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::FOLLOWER, 'follower' do |related_object|
    title { 'New Follower' }
    body { "#{related_object.username} is now following you" }
    application_target { "users/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::INVITE_REDEMPTION, 'invite_redemption' do |related_object|
    title { 'New Friends on Ello' }
    body { "#{related_object.username} has accepted your invitation to join Ello" }
    application_target { "users/#{related_object.id}" }
  end

  def initialize(type, destination_user_id, related_object=nil)
    @type, @destination_user_id, @related_object = type, destination_user_id, related_object
  end

  def build
    notification = Notification.new(metadata: common_metadata)

    decorator_for_type(@type).decorate(notification, @related_object)

    notification
  end

  private

  def decorator_for_type(desired_type)
    @@type_decorators.find{ |decorator| decorator.type == desired_type }
  end

  def common_metadata
    { destination_user_id: @destination_user_id }
  end
end
