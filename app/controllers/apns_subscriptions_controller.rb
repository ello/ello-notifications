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
    params.require(:bundle_id)
    params.require(:device_token)
    params.permit(:bundle_id, :device_token)
  end
end
