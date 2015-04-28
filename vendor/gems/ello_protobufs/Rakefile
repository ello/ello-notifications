$: << ::File.expand_path('../', __FILE__)
$: << ::File.expand_path('../spec', __FILE__)

require 'rubygems'
require 'rubygems/package_task'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

desc 'Default: run specs.'
task :default => :spec

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Starts a console'
task :console do
  require 'ello_protobufs'
  require 'pry'
  require 'faker'
  require 'factory_girl'

  FactoryGirl.reload
  ARGV.clear
  ::Pry.start
end

config = {
  plugin: 'ruby',
  destination: 'lib',
  source: 'definitions',
  package: 'ello_protobufs'
}

desc 'Compile Ello protocol buffers'
namespace :ello_protobufs do
  task :compile do
    command = []
    command << "protoc"
    command << "--#{config[:plugin]}_out=#{config[:destination]}"
    command << "-I #{config[:source]}"
    command << Dir["#{config[:source]}/**/*.proto"].join(" ")
    full_command = command.join(' ')

    puts full_command
    exec(full_command)
  end

  task :clean do
    files_to_clean = ::File.join(config[:destination], config[:package], '**', "*.pb.rb")
    ::Dir.glob(files_to_clean).each do |file|
      ::FileUtils.rm(file)
    end
  end
end
