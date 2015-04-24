require 'protobuf'
Dir[File.dirname(__FILE__) + '/ello_protobufs/*.rb'].each {|file| require file }

module ElloProtobufs
  def self.load_protobuf_factories
    load path_to_factories
  end

  private

  def self.path_to_factories
    File.dirname(__FILE__) + '/../spec/factories.rb'
  end
end
