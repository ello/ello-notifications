# frozen_string_literal: true

module ContextBuilders
  extend ActiveSupport::Concern

  included do
    def build_failed_context(opts = {})
      defaults = {
        success?: false,
        failure?: true,
        message: nil
      }
      double('Context', defaults.merge(opts))
    end

    def build_successful_context(opts = {})
      defaults = {
        success?: true,
        failure?: false
      }
      double('Context', defaults.merge(opts))
    end
  end
end

RSpec.configure do |config|
  config.include ContextBuilders
end
