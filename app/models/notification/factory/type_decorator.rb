class Notification::Factory::TypeDecorator

  module DSL
    def include_alert(value=nil)
      # allowing for block or direct value since this is a boolean
      @include_alert = ( block_given? ? yield : value )
    end

    def title
      @title = yield
    end

    def body
      @body = yield
    end

    def application_target
      @application_target = yield
    end
  end

  def initialize(type, human_readable_type, dsl_block)
    @type, @human_readable_type, @dsl_block = type, human_readable_type, dsl_block
  end

  attr_reader :type

  def decorate(notification, related_object)
    instance_exec(related_object, &@dsl_block)

    notification.include_alert = @include_alert unless @include_alert.nil?
    notification.title = @title
    notification.body = @body
    notification.metadata[:type] = @human_readable_type
    notification.metadata[:application_target] = @application_target

    reset
  end

  private

  include DSL

  def reset
    @title, @body, @application_target = nil
  end
end
