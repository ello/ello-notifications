class Notification::Factory
  @type_decorators = []
  class << self
    attr_reader :type_decorators
  end

  def self.build(*args)
    new(*args).build
  end

  def self.register_type(type, readable_type, &evaluator)
    self.type_decorators << TypeDecorator.new(type, readable_type, evaluator)
  end

  register_type ElloProtobufs::NotificationType::REPOST, 'repost' do |related_object|
    title { I18n.t('notification_factory.repost.title') }
    body { I18n.t('notification_factory.repost.body', username: related_object.author.username) }
    application_target { "posts/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::POST_COMMENT, 'post_comment' do |related_object|
    title { I18n.t('notification_factory.post_comment.title') }
    body { I18n.t('notification_factory.post_comment.body', username: related_object.author.username) }
    application_target { "posts/#{related_object.parent_post_id}/comments/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::POST_MENTION, 'post_mention' do |related_object|
    title { I18n.t('notification_factory.post_mention.title') }
    body { I18n.t('notification_factory.post_mention.body', username: related_object.author.username) }
    application_target { "posts/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::COMMENT_MENTION, 'comment_mention' do |related_object|
    title { I18n.t('notification_factory.comment_mention.title') }
    body { I18n.t('notification_factory.comment_mention.body', username: related_object.author.username) }
    application_target { "posts/#{related_object.parent_post_id}/comments/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::FOLLOWER, 'follower' do |related_object|
    title { I18n.t('notification_factory.follower.title') }
    body { I18n.t('notification_factory.follower.body', username: related_object.username) }
    application_target { "users/#{related_object.id}" }
  end

  register_type ElloProtobufs::NotificationType::INVITE_REDEMPTION, 'invite_redemption' do |related_object|
    title { I18n.t('notification_factory.invite_redemption.title') }
    body { I18n.t('notification_factory.invite_redemption.body', username: related_object.username) }
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
    self.class.type_decorators.find{ |decorator| decorator.type == desired_type }
  end

  def common_metadata
    { destination_user_id: @destination_user_id }
  end
end
