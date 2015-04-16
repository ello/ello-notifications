class ApnsSubscriptionsController < ApplicationController
  respond_to :json

  def create
    result = APNS::CreateSubscription.call(create_params)

    if result.success?
      render json: { }
    else
      render json: { error: result.message }, status: 403
    end
  end

  private

  def create_params
    params.require(:bundle_id)
    params.require(:device_token)
    params.permit(:bundle_id, :device_token)
  end
end
