# Ello Notifications Service [![Circle CI](https://circleci.com/gh/ello/ello-notifications.svg?style=svg&circle-token=376793a29ced1c232fe8b82e7499effbfe0bb2ee)](https://circleci.com/gh/ello/ello-notifications)

## Responsibilities

- registration of devices with Amazon SNS
- generation and dispatch of push notifications to mobile devices
- logging and processing of delivery failures

## Requirements

- Ruby 2.2.0
- Postgresql

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
