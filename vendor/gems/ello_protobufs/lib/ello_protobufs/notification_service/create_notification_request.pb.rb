# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'


##
# Imports
#
require 'ello_protobufs/user.pb'
require 'ello_protobufs/comment.pb'
require 'ello_protobufs/post.pb'
require 'ello_protobufs/notification_type.pb'

module ElloProtobufs
  module NotificationService

    ##
    # Message Classes
    #
    class CreateNotificationRequest < ::Protobuf::Message; end


    ##
    # Message Fields
    #
    class CreateNotificationRequest
      required ::ElloProtobufs::NotificationType, :type, 1, :default => ::ElloProtobufs::NotificationType::UNSPECIFIED
      required :uint32, :destination_user_id, 2
      optional ::ElloProtobufs::Post, :post, 3
      optional ::ElloProtobufs::User, :user, 4
      optional ::ElloProtobufs::Comment, :comment, 5
    end

  end

end

