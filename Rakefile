#!/usr/bin/env rake
require 'mongoid'
require 'typhoeus'
require 'date'
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

desc "Take snapshot. Ex: rake shapshot[2012-1-25]"
task :snapshot, :date do |t, args|
  date = Date.parse(args[:date])
  puts "Taking snapshot for #{date}"
  hydra = Typhoeus::Hydra.new
  snap = Snapshot.find_or_initialize_by(date: date)
  Keyword.all.each do |k|
    beg_range = date
    end_range = date+1
    key = k.name.gsub(/\s/, '%20')
    query = "http://api.thriftdb.com/api.hnsearch.com/items/_search?q=#{key}&limit=0&filter[fields][create_ts]=[#{beg_range}T00:00:00Z%20TO%20#{end_range}T00:00:00Z]"
    req = Typhoeus::Request.new(query)
    req.on_complete do |res|
      hits = JSON.parse(res.body)['hits']
      if snap.persisted?
        t = snap.terms.find_or_initialize_by(name: k.name)
        if t.persisted?
          # assume overall count exists
          t.update_attribute(daily_count: hits)
        else
          # todo: get total hits
          t.daily_count = hits
          t.category = k.category
          t.save
        end
      else
        # todo: get total hits
        snap.terms << Term.build(name: k.name, category: k.category, daily_count: hits)
        snap.save
      end

      stat = k.stats.where(created_at: {"$gte" => DateTime.parse(beg_range),"$lt" => DateTime.parse(end_range)})
      if stat.empty?
        # todo: get total hits
        k.stats.create(daily_count: hits)
      else
        # assume overall count exists
        stat.update_attribute(:daily_count, hits)
      end
    end
  end
end

def get_total_hits(keyword, date=Date.today)
  query = "http://api.thriftdb.com/api.hnsearch.com/items/_search?q=#{key}&limit=0&filter[fields][create_ts]=[*%20TO%20#{date}T00:00:00Z]"
  res = Typhoeus::Request.get(query)
  JSON.parse(res.body)['hits']
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
      diff = if k.stats.exists?
        count_yesterday = k.stats.desc(:created_at).first.count
        hits-count_yesterday   
      else
        0
      end
      
      s.terms << Term.new(name: k.name, category: k.category, count: hits, daily_count: diff)
      k.stats << Stat.new(count: hits, daily_count: diff)
      print '*'
    end
    hydra.queue(request)
    print '.'
  end
  hydra.run
  s.save
end
