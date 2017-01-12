require 'rails_helper'

describe HandleStreamEvent do
  before do
    allow(SnsService).to receive(:subscribe_to_announcements) { subscribe_response }
    allow(SnsService).to receive(:unsubscribe_from_topic)
  end

  let(:subscribe_response) do
    double(:subscribe_response, arn: 'arn:sns:foo')
  end

  describe 'user_created' do
    let(:record) do
      {
        'id' => 999_999_999,
        # ... properties excluded for test brevity
        'push_notification_preferences' => {
          'announcements' => true # New user always defaults to true
        }
      }
    end

    it 'should create a user with notify_of_announcements as true' do
      described_class.call(kind: 'user_was_created', record: record)
      expect(User.last.id).to eq(999_999_999)
      expect(User.last.notify_of_announcements).to eq true
    end
  end

  describe 'user deleted' do
    let!(:user) { create(:user) }
    let(:record) { { 'id' => user.id } }
    let!(:sub1) do
      create(:device_subscription, :apns,
             logged_in_user_id: user.id,
             announcement_subscription_arn: 'abc123')
    end
    let!(:sub2) do
      create(:device_subscription, :apns,
             logged_in_user_id: user.id,
             announcement_subscription_arn: 'def345')
    end

    it 'should delete the existing user' do
      described_class.call(kind: 'user_was_deleted', record: record)
      expect(User.where(id: user.id)).to be_empty
    end

    it 'should unsubscribe all the user devices from the announcement topic' do
      expect(SnsService).to receive(:unsubscribe_from_topic).with('abc123')
      expect(SnsService).to receive(:unsubscribe_from_topic).with('def345')
      described_class.call(kind: 'user_was_deleted', record: record)
    end

    it 'should remove the topic subscription from the device subscription' do
      described_class.call(kind: 'user_was_deleted', record: record)
      expect(sub1.reload.announcement_subscription_arn).to be nil
      expect(sub2.reload.announcement_subscription_arn).to be nil
    end
  end

  describe 'user_changed_subscription_preferences' do
    context 'new user(to system) - no subscriptions - wants announcements' do
      let(:record) do
        {
          'id' => 999_999_997,
          'push_notification_preferences' => {
            'announcements' => true
          }
        }
      end

      it 'creates a user' do
        described_class.call(kind: 'user_changed_subscription_preferences', record: record)
        expect(User.last.id).to eq(999_999_997)
        expect(User.last.notify_of_announcements).to eq true
      end
    end

    context 'existing user - has devices - wants announcements' do
      let!(:user) { create(:user, notify_of_announcements: false) }
      let!(:sub1) do
        create(:device_subscription, :apns,
               logged_in_user_id: user.id,
               announcement_subscription_arn: nil,
               build_version: 6000)
      end
      let!(:sub2) do
        create(:device_subscription, :apns,
               logged_in_user_id: user.id,
               announcement_subscription_arn: nil,
               build_version: 6000)
      end
      let!(:sub3) do
        create(:device_subscription, :apns,
               logged_in_user_id: user.id,
               announcement_subscription_arn: nil,
               build_version: 1000) # does not support announcements
      end
      let(:record) do
        {
          'id' => user.id,
          'push_notification_preferences' => {
            'announcements' => true
          }
        }
      end

      it 'updates the user' do
        described_class.call(kind: 'user_changed_subscription_preferences', record: record)
        expect(user.reload.notify_of_announcements).to eq true
      end

      it 'subscribes each device to topic and updated the announcement arn' do
        expect(SnsService).to receive(:subscribe_to_announcements).with(sub1.endpoint_arn) { subscribe_response }
        expect(SnsService).to receive(:subscribe_to_announcements).with(sub2.endpoint_arn) { double(:subscribe_response, arn: 'arn:sns:baz') }
        expect(SnsService).not_to receive(:subscribe_to_announcements).with(sub3.endpoint_arn)
        described_class.call(kind: 'user_changed_subscription_preferences', record: record)
        expect(sub1.reload.announcement_subscription_arn).to eq 'arn:sns:foo'
        expect(sub2.reload.announcement_subscription_arn).to eq 'arn:sns:baz'
        expect(sub3.reload.announcement_subscription_arn).to eq nil
      end

    end

    context 'existing user - has devices - has subscription - no announcements' do
      let!(:user) { create(:user, notify_of_announcements: false) }
      let!(:sub1) do
        create(:device_subscription, :apns,
               logged_in_user_id: user.id,
               announcement_subscription_arn: 'abc123',
               build_version: '6000')
      end
      let!(:sub2) do
        create(:device_subscription, :apns,
               logged_in_user_id: user.id,
               announcement_subscription_arn: 'def345',
               build_version: '6000')
      end
      let(:record) do
        {
          'id' => user.id,
          'push_notification_preferences' => {
            'announcements' => false
          }
        }
      end

      it 'updates the user' do
        described_class.call(kind: 'user_changed_subscription_preferences', record: record)
        expect(user.reload.notify_of_announcements).to eq false
      end


      it 'should unsubscribe all the user devices from the announcement topic' do
        expect(SnsService).to receive(:unsubscribe_from_topic).with('abc123')
        expect(SnsService).to receive(:unsubscribe_from_topic).with('def345')
        described_class.call(kind: 'user_was_deleted', record: record)
      end

      it 'should remove the topic subscription from the device subscription' do
        described_class.call(kind: 'user_was_deleted', record: record)
        expect(sub1.reload.announcement_subscription_arn).to be nil
        expect(sub2.reload.announcement_subscription_arn).to be nil
      end
    end
  end
end
