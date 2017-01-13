namespace :kinesis do
  desc 'Parses and saves events from Kinesis queue'
  task consumer: :environment do

    stream = StreamReader.new(
      stream_name: ENV['KINESIS_STREAM_NAME'],
      prefix:      ENV['KINESIS_STREAM_PREFIX'] || ''
    )

    stream.run!(batch_size: Integer(ENV['KINESIS_BATCH_SIZE'] || StreamReader::DEFAULT_BATCH_SIZE)) do |record, kind|
      HandleStreamEvent.call(record: record, kind: kind.underscore)
    end
  end
end