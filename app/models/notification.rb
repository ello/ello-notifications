# frozen_string_literal: true

class Notification
  include ActiveModel::Model

  attr_accessor :title,
                :body,
                :include_alert,
                :badge_count,
                :metadata

  alias include_alert? include_alert

  def initialize(opts = {})
    opts[:include_alert] = true unless opts.key?(:include_alert)
    super(opts)
  end

  def metadata # rubocop:disable Lint/DuplicateMethods
    @metadata ||= {}
  end
end
