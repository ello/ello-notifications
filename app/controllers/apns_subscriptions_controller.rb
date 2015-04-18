class ApnsSubscriptionsController < ApplicationController
  respond_to :json

  def create
    result = APNS::CreateSubscription.call(required_params)

    render_result(result)
  end

  def destroy
    result = APNS::DeleteSubscription.call(required_params)

    render_result(result)
  end

  private

  def render_result(result)
    if result.success?
      render json: { }
    else
      render json: { error: result.message }, status: 403
    end
  end

  def required_params
    params.require(:bundle_identifier)
    params.require(:platform_device_identifier)
    params.require(:logged_in_user_id)
    params.permit(:bundle_identifier, :platform_device_identifier, :logged_in_user_id)
  end
end
