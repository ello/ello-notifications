class ApnsSubscriptionsController < ApplicationController
  def create
    result = APNS::CreateSubscription.call(required_params)

    render_interactor_result(result)
  end

  def destroy
    result = APNS::DeleteSubscription.call(required_params)

    render_interactor_result(result)
  end

  private

  def required_params
    params.require(:bundle_identifier)
    params.require(:platform_device_identifier)
    params.require(:logged_in_user_id)
    params.permit(:bundle_identifier, :platform_device_identifier, :logged_in_user_id)
  end
end
