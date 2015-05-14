class NotificationsController < ApplicationController
  def create
    protobuf_request = ElloProtobufs::NotificationService::CreateNotificationRequest.decode_from(request.body)
    result = CreateNotification.call({
      request: protobuf_request
    })

    resp = service_response(result)
    render_protobuf_response(resp)
  end

end
