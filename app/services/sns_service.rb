# frozen_string_literal: true

class SnsService
  class ServiceError < StandardError
    attr_reader :original_exception

    def initialize(message, original_exception = nil)
      @original_exception = original_exception
      super(message)
    end
  end

  class << self
    ANNOUNCEMENT_TOPIC_ARN = ENV['ANNOUNCEMENT_TOPIC_ARN']

    def create_subscription_endpoint(subscription)
      if subscription.creatable_on_sns?
        sns = Aws::SNS::Client.new
        resp = sns.create_platform_endpoint(
          platform_application_arn: subscription.sns_application.application_arn,
          token: subscription.platform_device_identifier,
          attributes: { 'Enabled' => 'true' }
        )
        resp.endpoint_arn
      else
        message = "Cannot create device subscription: #{subscription.errors.full_messages.first}"
        raise ServiceError, message
      end
    rescue Aws::Errors::ServiceError => e
      raise ServiceError.new(e.message, e)
    end

    def delete_subscription_endpoint(subscription)
      sns = Aws::SNS::Client.new
      sns.delete_endpoint(
        endpoint_arn: subscription.endpoint_arn
      )
    rescue Aws::Errors::ServiceError => e
      raise ServiceError.new(e.message, e)
    end

    def enable_subscription_endpoint(subscription)
      sns = Aws::SNS::Client.new
      sns.set_endpoint_attributes(
        endpoint_arn: subscription.endpoint_arn,
        attributes: { 'Enabled' => 'true' }
      )
    rescue Aws::Errors::ServiceError => e
      raise ServiceError.new(e.message, e)
    end

    def deliver_notification(target_arn, message)
      sns = Aws::SNS::Client.new
      sns.publish({
                    target_arn: target_arn,
                    message_structure: 'json',
                    message: message.to_json
                  })
    rescue Aws::Errors::ServiceError => e
      raise ServiceError.new(e.message, e)
    end

    def publish_announcement(message)
      announcement_topic.publish(
        message_structure: 'json',
        message: message.to_json
      )
    end

    def subscribe_to_announcements(arn)
      announcement_topic.subscribe(
        protocol: 'application',
        endpoint: arn
      )
    end

    def unsubscribe_from_topic(subscription_arn)
      sns = Aws::SNS::Client.new
      sns.unsubscribe(subscription_arn: subscription_arn)
    end

    private

    def announcement_topic
      raise 'please set ANNOUNCEMENT_TOPIC_ARN env variable' unless ANNOUNCEMENT_TOPIC_ARN

      @announcement_topic ||= begin
        sns = Aws::SNS::Client.new
        Aws::SNS::Topic.new(ANNOUNCEMENT_TOPIC_ARN, client: sns)
      end
    end
  end
end
