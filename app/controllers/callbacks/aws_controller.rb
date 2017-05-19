require 'json'

# heavily influenced by the approach used in
# http://www.downrightlies.net/posts/2015/05/19/setting-up-ses-on-aws-to-send-emails-from-rails.html
class Callbacks::AwsController < ApplicationController

  before_action :log_incoming_message, :confirm_subscription, :verify_message_authenticity
  skip_before_filter :require_binary_request
  # before_filter :require_json_request

  def push_failed
    if !is_failure_notification?
      Rails.logger.info "Not a Failure Notification - exiting"
      return render json: {}
    end

    HandlePushFailure.perform_async(token)

    render json: {}
  end

  private

  def require_json_request
    render nothing: true, status: 406 unless request.content_type == 'application/json' || request.headers["Accept"] =~ /json/
  end

  def confirm_subscription
    if type == 'SubscriptionConfirmation'
      client = Aws::SNS::Client.new
      resp = client.confirm_subscription({
        topic_arn: topic_arn, # required
        token: confirmation_token, # required
      })
      if resp.successful?
        head :ok
      else
        head :not_acceptable
      end
    end
  end

  def verify_message_authenticity
    verifier = Aws::SNS::MessageVerifier.new
    if !verifier.authentic?(request.raw_post)
      Rails.logger.info "Not an authentic SNS message - exiting"
      head :not_acceptable
    end
  end

  def is_failure_notification?
    type == 'Notification' && status == 'FAILURE'
  end


  def log_incoming_message
    Rails.logger.info request.raw_post
  end

  def status
    @status ||= json['status']
  end

  def topic_arn
    @topic_arn ||= json['TopicArn']
  end

  def confirmation_token
    @confirmation_token ||= json['Token']
  end

  def token
    @token ||= json['delivery']['token']
  end

  def json
    @json ||= JSON.parse(request.raw_post)
  end

  def type
    request.headers['x-amz-sns-message-type']
  end

  def log_incoming_message
    Rails.logger.info request.raw_post
  end

end
