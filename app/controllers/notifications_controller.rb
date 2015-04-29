class NotificationsController < ApplicationController
  before_filter :require_binary_request

  def create
    protobuf_request = ElloProtobufs::NotificationService::CreateNotificationRequest.decode_from(request.body)
    result = CreateNotification.call({
      request: protobuf_request
    })

    render_create_response(result)
  end

  private

  def render_create_response(result)
    resp = ElloProtobufs::NotificationService::CreateNotificationResponse.new(success: result.success?)
    resp.failure_reason = result.failure_reason if result.failure?

    send_data resp.encode,
      type: 'application/octet-stream',
      status: result.failure? ? 403 : 200
  end

  def require_binary_request
    render nothing: true, status: 406 unless request.content_type == 'application/octet-stream' || request.headers["Accept"] =~ /octet-stream/
  end

end
