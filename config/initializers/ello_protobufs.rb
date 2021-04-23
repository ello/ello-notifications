# frozen_string_literal: true

if defined?(ElloProtobufs) && defined?(FactoryGirl)
  # Load the factory_girl factories provided by ElloProtobufs
  ElloProtobufs.load_protobuf_factories
end
