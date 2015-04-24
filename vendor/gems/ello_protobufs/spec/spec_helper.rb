$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'factory_girl'
require 'ello_protobufs'

Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each {|file| require file }
