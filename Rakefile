#!/usr/bin/env rake
require 'mongoid'
require 'typhoeus'
require 'debugger'

ENV['RACK_ENV'] = 'development' unless ENV['MONGOLAB_URI']

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
  s=Snapshot.new(date: Time.now)
  Keyword.all.each do |k|
    request = Typhoeus::Request.new("http://api.thriftdb.com/api.hnsearch.com/items/_search", :params => {q: k.name, limit: 0})
    request.on_complete do |response|
      hits = JSON.parse(response.body)['hits']
      count_yesterday = k.stats.desc(:created_at).first.count
      diff = hits-count_yesterday
      s.terms << Term.new(name: k.name, count: hits, daily_count: diff)
      k.stats << Stat.new(count: hits, daily_count: diff)
    end
    hydra.queue(request)
    print '.'
  end
  hydra.run
  s.save
end
