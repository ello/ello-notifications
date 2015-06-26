class Notification
  include ActiveModel::Model

  attr_accessor :title,
                :body,
                :include_alert,
                :badge_count,
                :metadata

  alias_method :include_alert?, :include_alert

  def initialize(opts={})
    opts[:include_alert] = true unless opts.has_key?(:include_alert)
    super(opts)
  end

  def metadata
    @metadata ||= {}
  end
end
