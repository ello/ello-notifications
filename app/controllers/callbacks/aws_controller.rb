require 'json'

# heavily influenced by the approach used in
# http://www.downrightlies.net/posts/2015/05/19/setting-up-ses-on-aws-to-send-emails-from-rails.html
class Callbacks::AWSController < ApplicationController

  before_action :log_incoming_message

  def push_failed

    if !aws_message.authentic?
      Rails.logger.info "Not an authentic SNS message - exiting"
      return render json: {}
    end

    if !is_failure_notification?
      Rails.logger.info "Not a Failure Notification - exiting"
      return render json: {}
    end

    if subscription = DeviceSubscription.where({platform_device_identifier: token}).first
      subscription.destroy
    end

    render json: {}
  end

  private

  def is_failure_notification?
    type == 'Notification' && status == 'FAILURE'
  end

  def aws_message
    @aws_message ||= AWS::SNS::Message.new request.raw_post
  end

  def log_incoming_message
    Rails.logger.info request.raw_post
  end

  def status
    @status ||= json['status']
  end

  def token
    @token ||= json['delivery']['token']
  end

  # Weirdly, AWS double encodes the JSON.
  def json
    @json ||= JSON.parse JSON.parse(request.raw_post)
  end

  def type
    request.headers['x-amz-sns-message-type']
  end

  def log_incoming_message
    Rails.logger.info request.raw_post
  end

end
