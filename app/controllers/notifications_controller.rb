class NotificationsController < ApplicationController
  before_filter :require_binary_with_return_json
  respond_to :json

  def create
    result = NotifyUser.call({
      destination_user_id: params.require(:destination_user_id),
      notification_type: params.require(:notification_type),
      request_body: request.body
    })

    render_interactor_result(result)
  end

  private

  def require_binary_with_return_json
    render nothing: true, status: 406 unless request.content_type == 'application/octet-stream' || request.headers["Accept"] =~ /json/
  end

end
