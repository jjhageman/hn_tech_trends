#!/usr/bin/env ruby
require 'mongoid'

Mongoid.load!("configs/mongoid.yml", 'development')
Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}
require 'irb'
IRB.start
