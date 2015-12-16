class ApnsDeliveryMetric < Metric

  namespace_all('ello-notifications.apns.delivery')

  class << self
    def track_delivery_success
      increment 'success'
    end

    def track_delivery_failure
      increment 'failure'
    end
  end

end

