# frozen_string_literal: true

class CreateTopicNotification
  include Interactor

  def call
    case topic
    when ElloProtobufs::TopicType::ANNOUNCEMENT_TOPIC
      send_announcement
    else
      unknown_topic
    end
  end

  private

  def send_announcement
    # Message is a key/value pairs where values are json strings
    message = {
      'default' => announcement_title,
      'APNS' => announcement_apple_body.to_json,
      'APNS_SANDBOX' => announcement_apple_body.to_json,
      'GCM' => announcement_google_body.to_json
    }

    SnsService.publish_announcement(message)
  rescue SnsService::ServiceError => e
    context.fail!(message: e.message)
  end

  def unknown_topic
    reason = ElloProtobufs::NotificationService::ServiceFailureReason::UNKNOWN_TOPIC_TYPE
    context.fail!(failure_reason: reason,
                  message: "Topic Notification to (#{context[:request].topic}) is not handled")
  end

  def topic
    context[:request].topic
  end

  def announcement
    context[:request].announcement
  end

  def announcement_title
    I18n.t('notification_factory.announcement.title')
  end

  def announcement_body
    I18n.t('notification_factory.announcement.body', header: announcement.header)
  end

  # JSON structure required to be sent to apple devices.
  def announcement_apple_body
    {
      aps: {
        alert: {
          title: announcement_title,
          body: announcement_body
        }
      },
      application_target: announcement.cta_href
    }
  end

  # JSON structure required to be sent to google devices.
  def announcement_google_body
    {
      data: {
        title: announcement_title,
        body: announcement_body,
        web_url: announcement.cta_href
      }
    }
  end
end
