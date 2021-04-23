# frozen_string_literal: true

class GcmSubscriptionMetric < Metric

  namespace_all('ello-notifications.gcm.subscription')

  class << self
    def track_creation_success(type)
      increment 'creation.success'
      increment "creation.success.#{type}"
    end

    def track_creation_failure
      increment 'creation.failure'
    end

    def track_deletion_success
      increment 'deletion.success'
    end

    def track_deletion_failure
      increment 'deletion.failure'
    end
  end

end
