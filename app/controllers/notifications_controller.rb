# frozen_string_literal: true

class NotificationsController < ApplicationController
  def create
    protobuf_request = ElloProtobufs::NotificationService::CreateNotificationRequest.decode_from(request.body)
    Honeybadger.context(protobuf_request: protobuf_request.to_hash)
    result = CreateNotification.call(request: protobuf_request)

    resp = service_response(result)
    render_protobuf_response(resp)
  end
end
