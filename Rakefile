#!/usr/bin/env rake
require 'mongoid'
require 'debugger'

Mongoid.load!("configs/mongoid.yml")
Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

desc "Bootstrap keywords"
task :keywords do
  keywords_file = File.open('keywords.txt')

  puts 'Deleting all Keywords'
  Keyword.delete_all

  keywords_file.each do |word|
    Keyword.create(name: word)
    print '.'
  end
  puts 'Done.'
end
