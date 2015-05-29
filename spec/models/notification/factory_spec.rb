require 'rails_helper'

describe Notification::Factory do
  describe 'building a repost notification' do
    let(:repost) { create(:protobuf_post, :repost) }

    subject { described_class.build(ElloProtobufs::NotificationType::REPOST, 2, repost) }

    it_behaves_like 'a notification with', focus: true do
      let(:destination_user_id) { 2 }
      let(:type) { 'repost' }
      let(:title) { 'New Repost' }
      let(:body) { "#{repost.author.username} has reposted one of your posts" }
      let(:application_target) { post_target(repost.id) }
    end
  end

  describe 'building a post_comment notification' do
    let(:comment) { create(:protobuf_comment) }

    subject { described_class.build(ElloProtobufs::NotificationType::POST_COMMENT, 2, comment) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { 2 }
      let(:type) { 'post_comment' }
      let(:title) { 'New Comment' }
      let(:body) { "#{comment.author.username} commented on your post" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
    end
  end

  describe 'building a repost_comment_to_repost_author notification' do
    let(:repost) { create(:protobuf_post, :repost) }
    let(:comment) { create(:protobuf_comment, parent_post: repost) }

    subject { described_class.build(ElloProtobufs::NotificationType::REPOST_COMMENT_TO_REPOST_AUTHOR, 2, comment) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { 2 }
      let(:type) { 'repost_comment_to_repost_author' }
      let(:title) { 'New Comment on Your Repost' }
      let(:body) { "#{comment.author.username} commented on your repost" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
    end
  end

  describe 'building a repost_comment_to_original_author notification' do
    let(:repost) { create(:protobuf_post, :repost) }
    let(:comment) { create(:protobuf_comment, parent_post: repost) }

    subject { described_class.build(ElloProtobufs::NotificationType::REPOST_COMMENT_TO_ORIGINAL_AUTHOR, 2, comment) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { 2 }
      let(:type) { 'repost_comment_to_original_author' }
      let(:title) { 'New Comment on a Repost of Your Post' }
      let(:body) { "#{comment.author.username} commented on #{comment.parent_post.author.username}'s repost of your post" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
    end
  end

  describe 'building a post_mention notification' do
    let(:post) { create(:protobuf_post) }

    subject { described_class.build(ElloProtobufs::NotificationType::POST_MENTION, 2, post) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { 2 }
      let(:type) { 'post_mention' }
      let(:title) { 'New Post Mention' }
      let(:body) { "#{post.author.username} mentioned you in a post" }
      let(:application_target) { post_target(post.id) }
    end
  end

  describe 'building a comment_mention notification' do
    let(:comment) { create(:protobuf_comment) }

    subject { described_class.build(ElloProtobufs::NotificationType::COMMENT_MENTION, 2, comment) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { 2 }
      let(:type) { 'comment_mention' }
      let(:title) { 'New Comment Mention' }
      let(:body) { "#{comment.author.username} mentioned you in a comment" }
      let(:application_target) { comment_target(comment.parent_post.id, comment.id) }
    end
  end

  describe 'building a follower notification' do
    let(:user) { create(:protobuf_user) }

    subject { described_class.build(ElloProtobufs::NotificationType::FOLLOWER, 2, user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { 2 }
      let(:type) { 'follower' }
      let(:title) { 'New Follower' }
      let(:body) { "#{user.username} is now following you" }
      let(:application_target) { user_target(user.id) }
    end
  end

  describe 'building a follower notification' do
    let(:user) { create(:protobuf_user) }

    subject { described_class.build(ElloProtobufs::NotificationType::INVITE_REDEMPTION, 2, user) }

    it_behaves_like 'a notification with' do
      let(:destination_user_id) { 2 }
      let(:type) { 'invite_redemption' }
      let(:title) { 'New Friends on Ello' }
      let(:body) { "#{user.username} has accepted your invitation to join Ello" }
      let(:application_target) { user_target(user.id) }
    end
  end

  def post_target(id, full_target=true)
    "ello://notifications/posts/#{id}"
  end

  def comment_target(parent_post_id, id)
    post_target(parent_post_id, false) + "/comments/#{id}"
  end

  def user_target(id)
    "ello://notifications/users/#{id}"
  end
end
