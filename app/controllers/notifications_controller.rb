class NotificationsController < ApplicationController
  def create_from_activity
    result = DeliverNotificationsForActivity.call(create_from_activity_params)

    render_interactor_result(result)
  end

  private

  def create_from_activity_params
    {
      activity: params.require(:activity).permit!,
      destination_user_id: params.require(:destination_user_id)
    }
  end

end
