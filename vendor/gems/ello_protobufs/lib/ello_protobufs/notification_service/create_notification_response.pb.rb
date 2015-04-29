# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'


##
# Imports
#
require 'ello_protobufs/notification_service/create_notification_failure_reason.pb'

module ElloProtobufs
  module NotificationService

    ##
    # Message Classes
    #
    class CreateNotificationResponse < ::Protobuf::Message; end


    ##
    # Message Fields
    #
    class CreateNotificationResponse
      required :bool, :success, 1
      optional ::ElloProtobufs::NotificationService::CreateNotificationFailureReason, :failure_reason, 2, :default => ::ElloProtobufs::NotificationService::CreateNotificationFailureReason::UNSPECIFIED
    end

  end

end

