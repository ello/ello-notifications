# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module ElloProtobufs
  module NotificationService

    ##
    # Message Classes
    #
    class CreateNotificationResponse < ::Protobuf::Message
      class FailureReason < ::Protobuf::Enum
        define :UNSPECIFIED, 0
        define :UNKNOWN_NOTIFICATION_TYPE, 1
      end

    end



    ##
    # Message Fields
    #
    class CreateNotificationResponse
      required :bool, :success, 1
      optional ::ElloProtobufs::NotificationService::CreateNotificationResponse::FailureReason, :failure_reason, 2, :default => ::ElloProtobufs::NotificationService::CreateNotificationResponse::FailureReason::UNSPECIFIED
    end

  end

end

