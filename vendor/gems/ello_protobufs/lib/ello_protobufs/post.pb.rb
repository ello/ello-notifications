# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'


##
# Imports
#
require 'ello_protobufs/user.pb'

module ElloProtobufs

  ##
  # Message Classes
  #
  class Post < ::Protobuf::Message; end


  ##
  # Message Fields
  #
  class Post
    required :uint32, :id, 1
    required :string, :token, 2
    optional :string, :href, 3
    required ::ElloProtobufs::User, :author, 4
    required :uint64, :created_at, 5
    required :uint64, :updated_at, 6
    optional :uint32, :reposted_source_id, 7
    optional :uint32, :reposted_via_id, 8
  end

end

