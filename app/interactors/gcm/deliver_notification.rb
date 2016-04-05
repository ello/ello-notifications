class GCM::DeliverNotification
  include Interactor

  before do
    require_arguments!(:endpoint_arn, :notification)
  end

  def call
    Rails.logger.debug "Delivering notification: #{context[:notification].inspect}, #{aps_options.inspect}"
    SnsService.deliver_notification(
        context[:endpoint_arn], {
        platform_key => { aps: aps_options }.merge(context[:notification].metadata).to_json
    })
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

  def aps_options
    { badge: context[:notification].badge_count }.tap do |opts|
      opts[:alert] = {
          title: context[:notification].title,
          body: context[:notification].body
      } if context[:notification].include_alert?
    end
  end

  def platform_key
    'GCM'
  end

end
