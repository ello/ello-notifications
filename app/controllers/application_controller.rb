class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::ImplicitRender

  before_filter :require_binary_request

  # custom error message from strong paramaters
  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    error = "Missing required paramater: #{parameter_missing_exception.param}"
    response = { error: error }
    render json: response, status: :unprocessable_entity
  end

  protected

  def require_binary_request
    render nothing: true, status: 406 unless request.content_type == 'application/octet-stream' || request.headers["Accept"] =~ /octet-stream/
  end

  def render_protobuf_response(resp)
    send_data resp.encode,
      type: 'application/octet-stream',
      status: resp.success ? 200 : 403
  end

  def service_response(result)
    resp = ElloProtobufs::NotificationService::ServiceResponse.new(success: result.success?)
    resp.failure_reason = result.failure_reason if result.failure?

    resp
  end

end
