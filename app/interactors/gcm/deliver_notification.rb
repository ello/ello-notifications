class GCM::DeliverNotification
  include Interactor

  before do
    require_arguments!(:endpoint_arn, :notification)
  end

  def call
    Rails.logger.debug "Delivering notification: #{context[:notification].inspect}, #{data_options.inspect}, #{notification_options.inspect}"
    payload = { data: data_options }
    payload[:data][:notification] = notification_options if context[:notification].include_alert?
    SnsService.deliver_notification(
      context[:endpoint_arn], {
        platform_key => payload.to_json
      }
    )
    GcmDeliveryMetric.track_delivery_success
  rescue SnsService::ServiceError => e
    GcmDeliveryMetric.track_delivery_failure
    context.fail!(message: e.message)
  end

  private

  def require_arguments!(*args)
    args.each do |argument|
      context.fail!(message: "Missing required argument: #{argument}") if context[argument].nil?
    end
  end

  def data_options
    context[:notification].metadata
  end

  def notification_options
    {
      title: context[:notification].title,
      body: context[:notification].body
    }
  end

  def platform_key
    'GCM'
  end

end
