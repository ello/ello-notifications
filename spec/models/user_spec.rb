# frozen_string_literal: true

require 'rails_helper'

describe User do

  describe '#notification_count' do
    it 'defaults to 0' do
      expect(subject.notification_count).to eq 0
    end
  end

  describe '#increment_notification_count' do
    subject { create(:user) }

    it 'increases the notification count by 1' do
      expect do
        subject.increment_notification_count
      end.to change(subject, :notification_count).by(1)
    end

    it 'persists the new value' do
      subject.increment_notification_count
      expect(subject).not_to be_changed
    end
  end

  describe '#reset_notification_count' do
    subject { create(:user, notification_count: 10) }

    it 'resets the notification count to 0' do
      expect do
        subject.reset_notification_count
      end.to change(subject, :notification_count).to(0)
    end

    it 'persists the new value' do
      subject.increment_notification_count
      expect(subject).not_to be_changed
    end
  end
end
