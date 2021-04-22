<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# Ello Notifications Service

[![Build Status](https://travis-ci.org/ello/ello-notifications.svg?branch=master)](https://travis-ci.org/ello/ello-notifications)
[![Code Climate](https://codeclimate.com/github/ello/ello-notifications/badges/gpa.svg)](https://codeclimate.com/github/ello/ello-notifications)
[![Security](https://hakiri.io/github/ello/ello-notifications/master.svg)](https://hakiri.io/github/ello/ello-notifications/master)
[![Dependencies](https://img.shields.io/gemnasium/ello/ello-notifications.svg)](https://gemnasium.com/ello/ello-notifications)

## Responsibilities

- registration of devices with Amazon SNS
- generation and dispatch of push notifications to mobile devices
- logging and processing of delivery failures

## Requirements

- Ruby 2.6.7 -- specified using `.ruby-version`
- Postgresql -- `brew install postgresql`
- Redis -- `brew install redis-server`
- Protobuf -- reference installation requirements in `ElloProtobufs` gem

## Setup

This project uses [dotenv-rails](https://github.com/bkeepers/dotenv) to
manage application configuration in development.  To get started, you
need to `cp .env.example .env` to setup the local development
environment variables.

## Lexicon

- **SNS** - Amazon Simple Notification Service - provider service for
  platform agnostic push notification delivery and management
- **APNS** - Apple Push Notification Service - provider service for
  end-user delivery of iOS push notifications
- **GCM** - Google Cloud Messaging - provider service for end-user
  delivery of Android push notifications

## Service Authentication

We are using basic auth for service authentication.  It's not a robost
enough solution once we have multiple services in play, but it will
suffice for now without making things overly complicated.  Check the
`.env` file for the proper environment variables related to basic auth.
The same values will need to be used by clients that communicate with
the service.

## AWS Configuration

In order to communicate with SNS, the notifications service needs to be
configured with an access key, secret, and specified region.  The key
pair only needs access to SNS, not other AWS components.

## Testing Locally

Since protocol buffers are a binary communication format, you have to
test the notification creation end-points with encoded binary directly.
Chrome extensions like Postman and XHR Poster don't work well for this
because of how they treat backslashes in the raw body as real
backslashes rather than escaping characters for multi-byte characters.

As a result, testing with curl is recommended:

```bash
curl http://lvh.me:3000/notifications/create --data-binary @./relative/path/to/request_object -H "Content-Type: application/octet-stream" -H "Accept: application/octet-stream"
```

In the example above, the encoded data for a notification creation has
been saved to a test file, which is sent as binary by curl.  You can easily encode
test objects from the Rails console:

```ruby
f = File.open('./request_object', 'w:ASCII-8BIT')
ElloProtobufs::SomeService::CreateResourceRequest.new({ object_param: 'value' }).encode_to(f)
f.close
```

The response from the server will also be binary information, and in
order to decode it, you will have to decode it into a response object:

```ruby
f = File.open('./response_object', 'r:ASCII-8BIT')
response = ElloProtobufs::SomeService::CreateResourceResponse.decode_from(f)
f.close
```

## License
Ello Notifications is released under the [MIT License](blob/master/LICENSE.txt)

## Code of Conduct
Ello was created by idealists who believe that the essential nature of all human beings is to be kind, considerate, helpful, intelligent, responsible, and respectful of others. To that end, we will be enforcing [the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open source projects. If you don’t follow the rules, you risk being ignored, banned, or reported for abuse.
