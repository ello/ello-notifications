# Ello Notifications Service [![Circle CI](https://circleci.com/gh/ello/ello-notifications.svg?style=svg&circle-token=376793a29ced1c232fe8b82e7499effbfe0bb2ee)](https://circleci.com/gh/ello/ello-notifications)

## Responsibilities

- registration of devices with Amazon SNS
- generation and dispatch of push notifications to mobile devices
- logging and processing of delivery failures

## Requirements

- Ruby 2.2.0 -- specified using `.ruby-version`
- Postgresql -- `brew install postgresql`
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

## Testing Locally

Since protocol buffers are a binary communication format, you have to
test the notification creation end-points with encoded binary directly.
Chrome extensions like Postman and XHR Poster don't work well for this
because of how they treat backslashes in the raw body as real
backslashes rather than escaping characters for multi-byte characters.

As a result, testing with curl is recommended:

```bash
curl http://lvh.me:3000/users/2/notifications/follower --data-binary @./relative/path/to/binaryfile -H "Content-Type: application/octet-stream" -H "Accept: application/json"
```

In the example above, the encoded data for a user record has been saved
to a test file, which is sent as binary by curl.  You can easily encode
test objects from the Rails console:

```ruby
f = File.open('./binaryfile', 'w:ASCII-8BIT')
FactoryGirl.create(:protobuf_user, id: 4).encode_to(f)
f.close
```
