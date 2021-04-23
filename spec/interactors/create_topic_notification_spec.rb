# frozen_string_literal: true

require 'rails_helper'

describe CreateTopicNotification do

  describe 'Announcements' do
    before { allow(SnsService).to receive(:publish_announcement) }

    let(:request) do
      ElloProtobufs::NotificationService::CreateTopicNotificationRequest.new(
        topic: ElloProtobufs::TopicType::ANNOUNCEMENT_TOPIC,
        announcement: create(:protobuf_announcement)
      )
    end

    it 'calls SnsService.publish_announcement' do
      expected = {
        'default' => 'New Announcement',
        'APNS' => {
          aps: {
            alert: {
              title: 'New Announcement',
              body: 'header'
            }
          },
          application_target: 'http://asdf.com'
        }.to_json,
        'APNS_SANDBOX' => {
          aps: {
            alert: {
              title: 'New Announcement',
              body: 'header'
            }
          },
          application_target: 'http://asdf.com'
        }.to_json,
        'GCM' => {
          data: {
            title: 'New Announcement',
            body: 'header',
            web_url: 'http://asdf.com'
          }
        }.to_json
      }
      expect(SnsService).to receive(:publish_announcement).with(expected)
      described_class.call(request: request)
    end
  end
end
