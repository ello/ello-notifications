# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module ElloProtobufs

  ##
  # Message Classes
  #
  class User < ::Protobuf::Message; end


  ##
  # Message Fields
  #
  class User
    required :uint32, :id, 1
    required :string, :href, 2
    required :string, :username, 3
    required :string, :name, 4
    required :uint64, :created_at, 5
    required :uint64, :updated_at, 6
  end

end

