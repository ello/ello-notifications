require 'spec_helper'

describe ElloProtobufs do
  describe '.load_protobuf_factories' do
    it 'loads the protobuf factories provided by the gem' do
      FactoryGirl.factories.clear
      ElloProtobufs.load_protobuf_factories
      expect(FactoryGirl.factory_by_name(:protobuf_user)).to_not be_nil
      expect(FactoryGirl.factory_by_name(:protobuf_post)).to_not be_nil
    end
  end

  it 'has a version number' do
    expect(ElloProtobufs::VERSION).not_to be nil
  end
end
