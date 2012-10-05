#!/usr/bin/env rake
require 'mongoid'
require 'typhoeus'

ENV['RACK_ENV'] = 'development' unless ENV['MONGOLAB_URI']

Mongoid.load!("configs/mongoid.yml", ENV['RACK_ENV'])
Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

desc "Bootstrap keywords"
task :keywords do
  keywords_file = File.open('keywords.txt')

  puts 'Deleting all Keywords'
  Keyword.delete_all

  keywords_file.each do |word|
    Keyword.create(name: word.strip)
    print '.'
  end
  puts 'Done.'
end

desc "Update keyword stats"
task :update_stats do
  hydra = Typhoeus::Hydra.new
  Keyword.all.each do |k|
    request = Typhoeus::Request.new("http://api.thriftdb.com/api.hnsearch.com/items/_search", :params => {:q => k.name})
    request.on_complete do |response|
      hits = JSON.parse(response.body)['hits']
      k.stats << Stat.new(count: hits)
      #k.push(:counts, hits)
      #k.pop(:counts, -1) if k.counts.size > 30
    end
    hydra.queue(request)
    #response = Typhoeus::Request.get("http://api.thriftdb.com/api.hnsearch.com/items/_search", :params => {:q => k.name})
    #hits = JSON.parse(response.body)['hits']
    #k.push(:counts, hits)
    #k.pop(:counts, 1) if k.counts.size > 30
    print '.'
  end
  hydra.run
end
