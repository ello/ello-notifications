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
    let(:repost) { create(:protobuf_post, :repost) }

    subject { described_class.build(ElloProtobufs::NotificationType::REPOST, destination_user, repost) }

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
    let(:comment) { create(:protobuf_comment) }

    subject { described_class.build(ElloProtobufs::NotificationType::POST_COMMENT, destination_user, comment) }

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
    let(:repost) { create(:protobuf_post, :repost) }
    let(:comment) { create(:protobuf_comment, parent_post: repost) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_COMMENT_TO_REPOST_AUTHOR, destination_user, comment)
    end

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
    let(:repost) { create(:protobuf_post, :repost) }
    let(:comment) { create(:protobuf_comment, parent_post: repost) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_COMMENT_TO_ORIGINAL_AUTHOR,
                            destination_user,
                            comment)
    end

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
    let(:love) { create(:protobuf_love) }

    subject { described_class.build(ElloProtobufs::NotificationType::POST_LOVE, destination_user, love) }

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
    let(:repost) { create(:protobuf_post, :repost) }
    let(:love) { create(:protobuf_love, post: repost) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_LOVE_TO_REPOST_AUTHOR,
                            destination_user,
                            love)
    end

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
    let(:repost) { create(:protobuf_post, :repost) }
    let(:love) { create(:protobuf_love, post: repost) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_LOVE_TO_ORIGINAL_AUTHOR,
                            destination_user,
                            love)
    end

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
    let(:post) { create(:protobuf_post) }

    subject { described_class.build(ElloProtobufs::NotificationType::POST_MENTION, destination_user, post) }

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
    let(:comment) { create(:protobuf_comment) }

    subject { described_class.build(ElloProtobufs::NotificationType::COMMENT_MENTION, destination_user, comment) }

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
    let(:user) { create(:protobuf_user) }

    subject { described_class.build(ElloProtobufs::NotificationType::FOLLOWER, destination_user, user) }

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
    let(:user) { create(:protobuf_user) }

    subject { described_class.build(ElloProtobufs::NotificationType::INVITE_REDEMPTION, destination_user, user) }

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
    let(:watch) { create(:protobuf_watch) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::POST_WATCH,
                            destination_user,
                            watch)
    end

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
    let(:comment) { create(:protobuf_comment) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::POST_COMMENT_TO_WATCHER,
                            destination_user,
                            comment)
    end

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
    let(:repost) { create(:protobuf_post, :repost) }
    let(:watch) { create(:protobuf_watch, post: repost) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_WATCH_TO_REPOST_AUTHOR,
                            destination_user,
                            watch)
    end

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
    let(:repost) { create(:protobuf_post, :repost) }
    let(:watch) { create(:protobuf_watch, post: repost) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::REPOST_WATCH_TO_ORIGINAL_AUTHOR,
                            destination_user,
                            watch)
    end

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
    let(:announcement) { create(:protobuf_announcement, header: 'Header', body: 'Body', cta_href: 'http://asdf.com') }

    subject do
      described_class.build(ElloProtobufs::NotificationType::ANNOUNCEMENT,
                            destination_user,
                            announcement)
    end

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
    let(:submission) { create(:protobuf_artist_invite_submission) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::ARTIST_INVITE_SUBMISSION_APPROVED,
                            destination_user,
                            submission)
    end

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'artist_invite_submission_approved' }
      let(:include_alert) { true }
      let(:title) { 'Artist Invite Submission Accepted' }
      let(:body) { "Your submission to the Artist Invite Title Artist Invite has been accepted ✌️ " }
      let(:application_target) { submission.href }
      let(:web_url) { submission.href }
    end
  end

  describe 'building an appoved artist invite submission for followers notification' do
    let(:post) { create(:protobuf_post) }
    let(:submission) { create(:protobuf_artist_invite_submission, post: post) }

    subject do
      described_class.build(ElloProtobufs::NotificationType::APPROVED_ARTIST_INVITE_SUBMISSION_FOR_FOLLOWERS,
                            destination_user,
                            submission)
    end

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { destination_user.id }
      let(:type) { 'approved_artist_invite_submission_for_followers' }
      let(:include_alert) { true }
      let(:title) { 'Artist Invite Submission' }
      let(:body) { "@#{submission.post.author.username}'s submission to #{submission.title} was accepted" }
      let(:application_target) { "notifications/posts/#{submission.post.id}" }
      let(:web_url) { submission.post.href }
    end
  end

  def post_target(id, _full_target = true)
    "notifications/posts/#{id}"
  end

  def comment_target(parent_post_id, id)
    post_target(parent_post_id, false) + "/comments/#{id}"
  end

  def user_target(id)
    "notifications/users/#{id}"
  end
end
