# frozen_string_literal: true

class GcmDeliveryMetric < Metric

  namespace_all('ello-notifications.gcm.delivery')

  class << self
    def track_delivery_success
      increment 'success'
    end

    def track_delivery_failure
      increment 'failure'
    end
  end

end
