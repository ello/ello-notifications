# frozen_string_literal: true

namespace :kinesis do
  desc 'Parses and saves events from Kinesis queue'
  task consumer: :environment do
    # Per http://chrisstump.online/2016/02/12/rails-production-eager-loading/,
    # Rails doesn't trigger eager loading in rake tasks for performance
    # reasons even when it's turned on for the environment in general, so we
    # need to do it manually (since the consumer is threaded)
    Rails.application.eager_load!

    stream = StreamReader.new(
      stream_name: ENV['KINESIS_STREAM_NAME'],
      prefix: ENV['KINESIS_STREAM_PREFIX'] || ''
    )

    stream.run! do |record, kind|
      HandleStreamEvent.call(record: record, kind: kind.underscore)
    end
  end
end
