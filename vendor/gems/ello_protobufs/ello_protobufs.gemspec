# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ello_protobufs/version'

Gem::Specification.new do |spec|
  spec.name          = "ello_protobufs"
  spec.version       = ElloProtobufs::VERSION
  spec.authors       = ["Bob Bonifield"]
  spec.email         = ["bob@ello.co"]

  spec.summary       = %q{Protocol buffers for micro-service data serialization/transfer}
  spec.homepage      = "http://github.com/ello/ello_protobufs"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'protobuf', '~> 3.5.0'
end
