class Notification::Factory
  @type_decorators = []
  class << self
    attr_reader :type_decorators
  end

  def self.build(*args)
    new(*args).build
  end

  def self.register_type(type, readable_type, &evaluator)
    type_decorators << TypeDecorator.new(type, readable_type, evaluator)
  end

  register_type ElloProtobufs::NotificationType::REPOST, 'repost' do |related_object|
    title { I18n.t('notification_factory.repost.title') }
    body { I18n.t('notification_factory.repost.body', username: related_object.author.username) }
    application_target { "notifications/posts/#{related_object.id}" }
    web_url { related_object.href }
  end

  register_type ElloProtobufs::NotificationType::POST_COMMENT, 'post_comment' do |related_object|
    title { I18n.t('notification_factory.post_comment.title') }
    body { I18n.t('notification_factory.post_comment.body', username: related_object.author.username) }
    application_target { "notifications/posts/#{related_object.parent_post.id}/comments/#{related_object.id}" }
    web_url { related_object.parent_post.href }
  end

  register_type ElloProtobufs::NotificationType::REPOST_COMMENT_TO_REPOST_AUTHOR,
                'repost_comment_to_repost_author' do |related_object|
    title { I18n.t('notification_factory.repost_comment_to_repost_author.title') }
    body do
      I18n.t('notification_factory.repost_comment_to_repost_author.body', username: related_object.author.username)
    end
    application_target { "notifications/posts/#{related_object.parent_post.id}/comments/#{related_object.id}" }
    web_url { related_object.parent_post.href }
  end

  register_type(ElloProtobufs::NotificationType::REPOST_COMMENT_TO_ORIGINAL_AUTHOR,
                'repost_comment_to_original_author') do |related_object|
    title { I18n.t('notification_factory.repost_comment_to_original_author.title') }
    body do
      I18n.t('notification_factory.repost_comment_to_original_author.body',
             username: related_object.author.username,
             reposter_username: related_object.parent_post.author.username)
    end
    application_target { "notifications/posts/#{related_object.parent_post.id}/comments/#{related_object.id}" }
    web_url { related_object.parent_post.href }
  end

  register_type ElloProtobufs::NotificationType::POST_LOVE, 'post_love' do |related_object|
    title { I18n.t('notification_factory.post_love.title') }
    body { I18n.t('notification_factory.post_love.body', username: related_object.user.username) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type(ElloProtobufs::NotificationType::REPOST_LOVE_TO_REPOST_AUTHOR,
                'repost_love_to_repost_author') do |related_object|
    title { I18n.t('notification_factory.repost_love_to_repost_author.title') }
    body { I18n.t('notification_factory.repost_love_to_repost_author.body', username: related_object.user.username) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::REPOST_LOVE_TO_ORIGINAL_AUTHOR,
                'repost_love_to_original_author' do |related_object|
    title { I18n.t('notification_factory.repost_love_to_original_author.title') }
    body do
      I18n.t('notification_factory.repost_love_to_original_author.body',
             username: related_object.user.username,
             reposter_username: related_object.post.author.username)
    end
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::POST_MENTION, 'post_mention' do |related_object|
    title { I18n.t('notification_factory.post_mention.title') }
    body { I18n.t('notification_factory.post_mention.body', username: related_object.author.username) }
    application_target { "notifications/posts/#{related_object.id}" }
    web_url { related_object.href }
  end

  register_type ElloProtobufs::NotificationType::COMMENT_MENTION, 'comment_mention' do |related_object|
    title { I18n.t('notification_factory.comment_mention.title') }
    body { I18n.t('notification_factory.comment_mention.body', username: related_object.author.username) }
    application_target { "notifications/posts/#{related_object.parent_post.id}/comments/#{related_object.id}" }
    web_url { related_object.parent_post.href }
  end

  register_type ElloProtobufs::NotificationType::FOLLOWER, 'follower' do |related_object|
    title { I18n.t('notification_factory.follower.title') }
    body { I18n.t('notification_factory.follower.body', username: related_object.username) }
    application_target { "notifications/users/#{related_object.id}" }
    web_url { related_object.href }
  end

  register_type ElloProtobufs::NotificationType::INVITE_REDEMPTION, 'invite_redemption' do |related_object|
    title { I18n.t('notification_factory.invite_redemption.title') }
    body { I18n.t('notification_factory.invite_redemption.body', username: related_object.username) }
    application_target { "notifications/users/#{related_object.id}" }
    web_url { related_object.href }
  end

  register_type ElloProtobufs::NotificationType::RESET_BADGE_COUNT, 'reset_badge_count' do |_|
    include_alert false
  end

  register_type ElloProtobufs::NotificationType::POST_WATCH, 'post_watch' do |related_object|
    title { I18n.t('notification_factory.post_watch.title') }
    body { I18n.t('notification_factory.post_watch.body', username: related_object.user.username) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::POST_COMMENT_TO_WATCHER, 'post_comment_to_watcher' do |related_object|
    title { I18n.t('notification_factory.post_comment_to_watcher.title') }
    body { I18n.t('notification_factory.post_comment_to_watcher.body', username: related_object.author.username) }
    application_target { "notifications/posts/#{related_object.parent_post.id}/comments/#{related_object.id}" }
    web_url { related_object.parent_post.href }
  end

  register_type ElloProtobufs::NotificationType::REPOST_WATCH_TO_REPOST_AUTHOR,
                'repost_watch_to_repost_author' do |related_object|
    title { I18n.t('notification_factory.repost_watch_to_repost_author.title') }
    body { I18n.t('notification_factory.repost_watch_to_repost_author.body', username: related_object.user.username) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::REPOST_WATCH_TO_ORIGINAL_AUTHOR,
                'repost_watch_to_original_author' do |related_object|
    title { I18n.t('notification_factory.repost_watch_to_original_author.title') }
    body do
      I18n.t('notification_factory.repost_watch_to_original_author.body',
             username: related_object.user.username,
             reposter_username: related_object.post.author.username)
    end
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::ANNOUNCEMENT, 'announcement' do |related_object|
    title { I18n.t('notification_factory.announcement.title') }
    body { I18n.t('notification_factory.announcement.body', header: related_object.header) }
    application_target { related_object.cta_href }
    web_url { related_object.cta_href }
  end

  register_type ElloProtobufs::NotificationType::ARTIST_INVITE_SUBMISSION_APPROVED, 'artist_invite_submission_approved' do |related_object|
    title { I18n.t('notification_factory.artist_invite_submission_approved.title') }
    body { I18n.t('notification_factory.artist_invite_submission_approved.body', artist_invite_title: related_object.title) }
    application_target { related_object.href }
    web_url { related_object.href }
  end

  register_type ElloProtobufs::NotificationType::APPROVED_ARTIST_INVITE_SUBMISSION_FOR_FOLLOWERS, 'approved_artist_invite_submission_for_followers' do |related_object|
    title { I18n.t('notification_factory.approved_artist_invite_submission_for_followers.title') }
    body { I18n.t('notification_factory.approved_artist_invite_submission_for_followers.body', author_username: related_object.post.author.username, artist_invite_title: related_object.title) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::FEATURED_CATEGORY_POST, 'featured_category_post' do |related_object|
    title { I18n.t('notification_factory.featured_category_post.title') }
    body { I18n.t('notification_factory.featured_category_post.body', {
      featured_by_username: related_object.featured_by.try(:username) || '@ello',
      category_name: related_object.category.title,
    }) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::FEATURED_CATEGORY_REPOST, 'featured_category_repost' do |related_object|
    title { I18n.t('notification_factory.featured_category_repost.title') }
    body { I18n.t('notification_factory.featured_category_repost.body', {
      featured_by_username: related_object.featured_by.try(:username) || '@ello',
      category_name: related_object.category.title,
    }) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::FEATURED_CATEGORY_POST_VIA_REPOST, 'featured_category_post_via_repost' do |related_object|
    title { I18n.t('notification_factory.featured_category_post_via_repost.title') }
    body { I18n.t('notification_factory.featured_category_post_via_repost.body', {
      featured_by_username: related_object.featured_by.try(:username) || '@ello',
      category_name: related_object.category.title,
    }) }
    application_target { "notifications/posts/#{related_object.post.id}" }
    web_url { related_object.post.href }
  end

  register_type ElloProtobufs::NotificationType::USER_ADDED_AS_FEATURED, 'user_added_as_featured' do |related_object|
    title { I18n.t('notification_factory.user_added_as_featured.title') }
    body { I18n.t('notification_factory.user_added_as_featured.body', {
      featured_by_username: related_object.featured_by.try(:username) || '@ello',
      category_name: related_object.category.title,
    }) }
    application_target { "notifications/categories/#{related_object.category.slug}" }
    web_url { "http://ello.co/discover/#{related_object.category.slug}" }
  end

  register_type ElloProtobufs::NotificationType::USER_ADDED_AS_CURATOR, 'user_added_as_curator' do |related_object|
    title { I18n.t('notification_factory.user_added_as_curator.title') }
    body { I18n.t('notification_factory.user_added_as_curator.body', {
      curator_by_username: related_object.curator_by.try(:username) || '@ello',
      category_name: related_object.category.title,
    }) }
    application_target { "notifications/categories/#{related_object.category.slug}" }
    web_url { "http://ello.co/discover/#{related_object.category.slug}" }
  end

  register_type ElloProtobufs::NotificationType::USER_ADDED_AS_MODERATOR, 'user_added_as_moderator' do |related_object|
    title { I18n.t('notification_factory.user_added_as_moderator.title') }
    body { I18n.t('notification_factory.user_added_as_moderator.body', {
      moderator_by_username: related_object.moderator_by.try(:username) || '@ello',
      category_name: related_object.category.title,
    }) }
    application_target { "notifications/categories/#{related_object.category.slug}" }
    web_url { "http://ello.co/discover/#{related_object.category.slug}" }
  end

  def initialize(type, destination_user, related_object = nil)
    @type = type
    @destination_user = destination_user
    @related_object = related_object
  end

  def build
    notification = Notification.new(badge_count: @destination_user.notification_count,
                                    metadata: common_metadata)

    # clone the decorator to prevent thread-safety issues
    decorator_for_type(@type).clone.decorate(notification, @related_object)

    notification
  end

  private

  def decorator_for_type(desired_type)
    self.class.type_decorators.find { |decorator| decorator.type == desired_type }
  end

  def common_metadata
    { destination_user_id: @destination_user.id }
  end
end
