# frozen_string_literal: true

require 'rails_helper'

describe Notification::Factory do
  let(:destination_user) { build_stubbed(:user) }

  describe '.build' do
    describe 'for thread safety reasons' do
      it 'clones the decorator before using it to decorate the notification' do
        comment = create(:protobuf_comment)
        cloned_decorator = instance_spy(Notification::Factory::TypeDecorator)
        allow_any_instance_of(Notification::Factory::TypeDecorator).to receive(:clone)
          .and_return(cloned_decorator)

        described_class.build(ElloProtobufs::NotificationType::POST_COMMENT, destination_user, comment)

        expect(cloned_decorator).to have_received(:decorate)
      end
    end
  end

  describe 'building a repost notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::REPOST, destination_user, repost) }

    let(:repost) { create(:protobuf_post, :repost) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'repost' }
      let(:include_alert) { true }
      let(:title) { 'New Repost' }
      let(:body) { "#{repost.author.username} has reposted one of your posts" }
      let(:application_target) { post_target(repost.id) }
      let(:web_url) { repost.href }
    end
  end

  describe 'building a post_comment notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::POST_COMMENT, destination_user, comment) }

    let(:comment) { create(:protobuf_comment) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'post_comment' }
      let(:include_alert) { true }
      let(:title) { 'New Comment' }
      let(:body) { "#{comment.author.username} commented on your post" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
      let(:web_url) { comment.parent_post.href }
    end
  end

  describe 'building a repost_comment_to_repost_author notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_COMMENT_TO_REPOST_AUTHOR, destination_user, comment)
    end

    let(:repost) { create(:protobuf_post, :repost) }
    let(:comment) { create(:protobuf_comment, parent_post: repost) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'repost_comment_to_repost_author' }
      let(:include_alert) { true }
      let(:title) { 'New Comment on Your Repost' }
      let(:body) { "#{comment.author.username} commented on your repost" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
      let(:web_url) { repost.href }
    end
  end

  describe 'building a repost_comment_to_original_author notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_COMMENT_TO_ORIGINAL_AUTHOR,
                            destination_user,
                            comment)
    end

    let(:repost) { create(:protobuf_post, :repost) }
    let(:comment) { create(:protobuf_comment, parent_post: repost) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'repost_comment_to_original_author' }
      let(:include_alert) { true }
      let(:title) { 'New Comment on a Repost of Your Post' }
      let(:body) do
        "#{comment.author.username} commented on #{comment.parent_post.author.username}'s repost of your post"
      end
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
      let(:web_url) { repost.href }
    end
  end

  describe 'building a post_love notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::POST_LOVE, destination_user, love) }

    let(:love) { create(:protobuf_love) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'post_love' }
      let(:include_alert) { true }
      let(:title) { 'New Love' }
      let(:body) { "#{love.user.username} loved your post" }
      let(:application_target) { post_target(love.post.id) }
      let(:web_url) { love.post.href }
    end
  end

  describe 'building a repost_love_to_repost_author notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_LOVE_TO_REPOST_AUTHOR,
                            destination_user,
                            love)
    end

    let(:repost) { create(:protobuf_post, :repost) }
    let(:love) { create(:protobuf_love, post: repost) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'repost_love_to_repost_author' }
      let(:include_alert) { true }
      let(:title) { 'New Love on Your Repost' }
      let(:body) { "#{love.user.username} loved your repost" }
      let(:application_target) { post_target(love.post.id) }
      let(:web_url) { love.post.href }
    end
  end

  describe 'building a repost_love_to_original_author notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_LOVE_TO_ORIGINAL_AUTHOR,
                            destination_user,
                            love)
    end

    let(:repost) { create(:protobuf_post, :repost) }
    let(:love) { create(:protobuf_love, post: repost) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'repost_love_to_original_author' }
      let(:include_alert) { true }
      let(:title) { 'New Love on a Repost of Your Post' }
      let(:body) { "#{love.user.username} loved #{love.post.author.username}'s repost of your post" }
      let(:application_target) { post_target(love.post.id) }
      let(:web_url) { love.post.href }
    end
  end

  describe 'building a post_mention notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::POST_MENTION, destination_user, post) }

    let(:post) { create(:protobuf_post) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'post_mention' }
      let(:include_alert) { true }
      let(:title) { 'New Post Mention' }
      let(:body) { "#{post.author.username} mentioned you in a post" }
      let(:application_target) { post_target(post.id) }
      let(:web_url) { post.href }
    end
  end

  describe 'building a comment_mention notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::COMMENT_MENTION, destination_user, comment) }

    let(:comment) { create(:protobuf_comment) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'comment_mention' }
      let(:include_alert) { true }
      let(:title) { 'New Comment Mention' }
      let(:body) { "#{comment.author.username} mentioned you in a comment" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
      let(:web_url) { comment.parent_post.href }
    end
  end

  describe 'building a follower notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::FOLLOWER, destination_user, user) }

    let(:user) { create(:protobuf_user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'follower' }
      let(:include_alert) { true }
      let(:title) { 'New Follower' }
      let(:body) { "#{user.username} is now following you" }
      let(:application_target) { user_target(user.id) }
      let(:web_url) { user.href }
    end
  end

  describe 'building an invite redemption notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::INVITE_REDEMPTION, destination_user, user) }

    let(:user) { create(:protobuf_user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'invite_redemption' }
      let(:include_alert) { true }
      let(:title) { 'New Friends on Ello' }
      let(:body) { "#{user.username} has accepted your invitation to join Ello" }
      let(:application_target) { user_target(user.id) }
      let(:web_url) { user.href }
    end
  end

  describe 'building a reset badge count notification' do
    subject { described_class.build(ElloProtobufs::NotificationType::RESET_BADGE_COUNT, destination_user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'reset_badge_count' }
      let(:include_alert) { false }
      let(:title) { nil }
      let(:body) { nil }
      let(:application_target) { nil }
      let(:web_url) { nil }
    end
  end

  describe 'building a post_watch notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::POST_WATCH,
                            destination_user,
                            watch)
    end

    let(:watch) { create(:protobuf_watch) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'post_watch' }
      let(:include_alert) { true }
      let(:title) { 'New Watcher on Post' }
      let(:body) { "#{watch.user.username} is watching your post" }
      let(:application_target) { post_target(watch.post.id) }
      let(:web_url) { watch.post.href }
    end
  end

  describe 'building a post_comment_to_watcher notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::POST_COMMENT_TO_WATCHER,
                            destination_user,
                            comment)
    end

    let(:comment) { create(:protobuf_comment) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'post_comment_to_watcher' }
      let(:include_alert) { true }
      let(:title) { 'New Comment on a Watched Post' }
      let(:body) { "#{comment.author.username} commented on a post you're watching" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
      let(:web_url) { comment.parent_post.href }
    end
  end

  describe 'building a repost_watch_to_repost_author notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_WATCH_TO_REPOST_AUTHOR,
                            destination_user,
                            watch)
    end

    let(:repost) { create(:protobuf_post, :repost) }
    let(:watch) { create(:protobuf_watch, post: repost) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'repost_watch_to_repost_author' }
      let(:include_alert) { true }
      let(:title) { 'New Watcher on a Repost' }
      let(:body) { "#{watch.user.username} is watching your repost" }
      let(:application_target) { post_target(watch.post.id) }
      let(:web_url) { watch.post.href }
    end
  end

  describe 'building a repost_watch_to_original_author notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_WATCH_TO_ORIGINAL_AUTHOR,
                            destination_user,
                            watch)
    end

    let(:repost) { create(:protobuf_post, :repost) }
    let(:watch) { create(:protobuf_watch, post: repost) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'repost_watch_to_original_author' }
      let(:include_alert) { true }
      let(:title) { 'New Watcher on a Reposted Post' }
      let(:body) { "#{watch.user.username} is watching #{watch.post.author.username}'s repost of your post" }
      let(:application_target) { post_target(watch.post.id) }
      let(:web_url) { watch.post.href }
    end
  end

  describe 'building an announcement notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::ANNOUNCEMENT,
                            destination_user,
                            announcement)
    end

    let(:announcement) { create(:protobuf_announcement, header: 'Header', body: 'Body', cta_href: 'http://asdf.com') }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'announcement' }
      let(:include_alert) { true }
      let(:title) { 'New Announcement' }
      let(:body) { announcement.header }
      let(:application_target) { announcement.cta_href }
      let(:web_url) { announcement.cta_href }
    end
  end

  describe 'building an appoved artist invite submission notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::ARTIST_INVITE_SUBMISSION_APPROVED,
                            destination_user,
                            submission)
    end

    let(:submission) { create(:protobuf_artist_invite_submission) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'artist_invite_submission_approved' }
      let(:include_alert) { true }
      let(:title) { 'Artist Invite Submission Accepted' }
      let(:body) { 'Your submission to the Artist Invite Title Artist Invite has been accepted ✌️ ' }
      let(:application_target) { submission.href }
      let(:web_url) { submission.href }
    end
  end

  describe 'building an appoved artist invite submission for followers notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::APPROVED_ARTIST_INVITE_SUBMISSION_FOR_FOLLOWERS,
                            destination_user,
                            submission)
    end

    let(:post) { create(:protobuf_post) }
    let(:submission) { create(:protobuf_artist_invite_submission, post: post) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'approved_artist_invite_submission_for_followers' }
      let(:include_alert) { true }
      let(:title) { 'Artist Invite Submission' }
      let(:body) { "#{submission.post.author.username}'s submission to #{submission.title} was accepted" }
      let(:application_target) { "notifications/posts/#{submission.post.id}" }
      let(:web_url) { submission.post.href }
    end
  end

  describe 'building an featured category post notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::FEATURED_CATEGORY_POST,
                            destination_user,
                            category_post)
    end

    let(:post) { create(:protobuf_post) }
    let(:category_post) { create(:protobuf_category_post, post: post) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'featured_category_post' }
      let(:include_alert) { true }
      let(:title) { 'Featured on Ello' }
      let(:body) { "#{category_post.featured_by.username} featured your post in #{category_post.category.title}." }
      let(:application_target) { "notifications/posts/#{category_post.post.id}" }
      let(:web_url) { category_post.post.href }
    end
  end

  describe 'building an featured category repost notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::FEATURED_CATEGORY_REPOST,
                            destination_user,
                            category_post)
    end

    let(:post) { create(:protobuf_post) }
    let(:category_post) { create(:protobuf_category_post, post: post) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'featured_category_repost' }
      let(:include_alert) { true }
      let(:title) { 'Featured on Ello' }
      let(:body) { "#{category_post.featured_by.username} featured your repost in #{category_post.category.title}." }
      let(:application_target) { "notifications/posts/#{category_post.post.id}" }
      let(:web_url) { category_post.post.href }
    end
  end

  describe 'building an featured category post via repost notification' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::FEATURED_CATEGORY_POST_VIA_REPOST,
                            destination_user,
                            category_post)
    end

    let(:post) { create(:protobuf_post) }
    let(:category_post) { create(:protobuf_category_post, post: post) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'featured_category_post_via_repost' }
      let(:include_alert) { true }
      let(:title) { 'Featured on Ello' }
      let(:body) do
        "#{category_post.featured_by.username} featured a repost of your post in #{category_post.category.title}."
      end
      let(:application_target) { "notifications/posts/#{category_post.post.id}" }
      let(:web_url) { category_post.post.href }
    end
  end

  describe 'building an category user via user added as featured' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::USER_ADDED_AS_FEATURED,
                            destination_user,
                            category_user)
    end

    let(:category_user) { create(:protobuf_category_user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'user_added_as_featured' }
      let(:include_alert) { true }
      let(:title) { 'Congrats!' }
      let(:body) do
        "#{category_user.featured_by.username} has featured you in #{category_user.category.title}. Tap to learn more."
      end
      let(:application_target) { 'notifications/ello.co/wtf/support/featured-members/' }
      let(:web_url) { 'https://ello.co/wtf/support/featured-members/' }
    end
  end

  describe 'building an category user via user added as curator' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::USER_ADDED_AS_CURATOR,
                            destination_user,
                            category_user)
    end

    let(:category_user) { create(:protobuf_category_user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'user_added_as_curator' }
      let(:include_alert) { true }
      let(:title) { 'Curate Ello' }
      let(:body) do
        "#{category_user.curator_by.username} has invited you to help curate #{category_user.category.title}."
      end
      let(:application_target) { "notifications/categories/#{category_user.category.slug}" }
      let(:web_url) { "http://ello.co/discover/#{category_user.category.slug}" }
    end
  end

  describe 'building an category user via user added as moderator' do
    subject do
      described_class.build(ElloProtobufs::NotificationType::USER_ADDED_AS_MODERATOR,
                            destination_user,
                            category_user)
    end

    let(:category_user) { create(:protobuf_category_user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'user_added_as_moderator' }
      let(:include_alert) { true }
      let(:title) { 'Moderate Ello' }
      let(:body) do
        "#{category_user.moderator_by.username} has invited you to help moderate #{category_user.category.title}."
      end
      let(:application_target) { "notifications/categories/#{category_user.category.slug}" }
      let(:web_url) { "http://ello.co/discover/#{category_user.category.slug}" }
    end
  end

  def post_target(id, _full_target = true) # rubocop:disable Style/OptionalBooleanParameter
    "notifications/posts/#{id}"
  end

  def comment_target(parent_post_id, id)
    post_target(parent_post_id, false) + "/comments/#{id}"
  end

  def user_target(id)
    "notifications/users/#{id}"
  end
end
