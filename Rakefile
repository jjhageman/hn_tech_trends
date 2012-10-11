#!/usr/bin/env rake
require 'mongoid'
require 'typhoeus'
require 'debugger'

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

desc "Update categories and keywords"
task :update_keyword_categories do
  categories = YAML.load(File.open('configs/keywords.yml'))
  categories.each do |c,k|
    k.each do |key|
      kw = Keyword.find_or_initialize_by(name: key)
      kw.category = c
      kw.save
      print '.'
    end
  end
  puts 'Done.'
end

desc "Backfill missing keywords and snapshots data"
task :backfill => [:backfill_keywords, :backfill_snapshots]

desc "Backfill keywords with missing daily counts"
task :backfill_keywords do
  Keyword.all.each do |k|
    ordered_stats = k.stats.asc(:created_at)
    first_stat = ordered_stats[0]
    first_stat.update_attribute(:daily_count, 0) unless first_stat.daily_count
    ordered_stats[1..-1].each_with_index do |s,i|
      s.update_attribute(:daily_count, (s.count - ordered_stats[i].count)) unless s.daily_count
      print '.'
    end
  end
  puts 'Done.'
end

desc "Backfill missing snapshots dates"
task :backfill_snapshots do
  keyword_dates = Keyword.first.stats.map{|s| s.created_at.to_date}.uniq
  snap_dates = Snapshot.all.map(&:date)
  missing_dates = keyword_dates - snap_dates
  missing_dates.each do |d|
    s = Snapshot.new(date: d)
    Keyword.all.each do |k|
      stat = k.stats.where(:created_at.gt => d.beginning_of_day, :created_at.lt => d.end_of_day).last
      s.terms.build(name: k.name, count: stat.count, daily_count: stat.daily_count)
      print '.'
    end
    s.save
  end
  puts 'Done.'
end

# http://api.thriftdb.com/api.hnsearch.com/items/_search?q=chrome&filter[fields][create_ts]=[2012-10-02T00:00:00Z%20TO%202012-10-03T00:00:00Z]
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
