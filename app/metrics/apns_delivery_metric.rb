class ApnsDeliveryMetric < Metric

  namespace_all('ello-notifications.apns.delivery')

  class << self
    def track_delivery_success(source = nil)
      increment 'success', 1, source: source
    end

    def track_delivery_failure(source = nil)
      increment 'failure', 1, source: source
    end
  end

end

