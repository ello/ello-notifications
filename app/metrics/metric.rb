require 'librato-rails'

class Metric

  class << self
    def increment(*args)
      new.increment(*args)
    end

    def measure(*args, &block)
      new.measure(*args, &block)
    end
    alias :timing :measure

    def namespace(namespace)
      yield new(namespace)
    end

    attr_reader :global_namespace
    def namespace_all(namespace)
      @global_namespace = namespace
    end

    def time
      start = Time.now
      yield
      ((Time.now - start) * 1000.0).to_i
    end
  end

  def initialize(namespace = nil)
    @namespace = namespace
  end

  def increment(name, count = 1, options = {})
    Librato.increment(build_key(name), options.merge(by: count))
    trace_metric 'increment', name, count, options
  end

  def measure(name, value = nil, options = {}, &block)
    Librato.measure(build_key(name), value, options, &block)
    trace_metric 'measure', name, value, options
  end
  alias :timing :measure

  private

  def trace_metric(kind, name, *info)
    Rails.logger.debug("METRIC: #{kind} #{name} #{info.inspect}") if ENV['LOG_LEVEL'] == 'debug'
  end

  def build_key(name)
    [self.class.global_namespace, @namespace, name].compact.join('.')
  end

end
