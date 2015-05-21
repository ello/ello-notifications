class DeviceSubscriptionsController < ApplicationController
  def create
    protobuf_request = ElloProtobufs::NotificationService::CreateDeviceSubscriptionRequest.decode_from(request.body)
    result = CreateDeviceSubscription.call(request: protobuf_request)

    resp = service_response(result)
    render_protobuf_response(resp)
  end

  def destroy
    protobuf_request = ElloProtobufs::NotificationService::DeleteDeviceSubscriptionRequest.decode_from(request.body)
    result = DeleteDeviceSubscription.call(request: protobuf_request)

    resp = service_response(result)
    render_protobuf_response(resp)
  end
end
