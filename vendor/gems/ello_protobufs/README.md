# Ello Proto Buffers

This gem includes the protobuf definitions and compiled protobuf data
transfer objects for the Ello domain.  The intent of this library
is to provide a common way to serialize/transfer Ello domain
objects between services.

For more information on Protocol Buffers, check the [Google Developer
resoruces](https://developers.google.com/protocol-buffers/).

## Installation

Add this line to the application's Gemfile:

```ruby
gem 'ello_protobufs'
```

And then execute:

    $ bundle

## Usage

Once added to your `Gemfile`, the protobufs will be available under
the `ElloProtobufs` namespace.  Behind the scenes, we're using
[localshred/protobuf](https://github.com/localshred/protobuf) for
the actual protobuf serialization/deserialization.

The gem provides some FactoryGirl factories for testing purposes in
implementing applications.  These can be loaded into your project by
adding `ElloProtobufs.load_protobuf_factories` in your `spec_helper.rb`
or `rails_helper.rb`.

## Development Requirements

- Protobuf 2.5.0 -- `brew tap homebrew/versions && brew install protobuf`

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then run `bundle exec console` for an interactive prompt that will allow
you to experiment.
