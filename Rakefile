#!/usr/bin/env rake
require 'mongoid'
require 'typhoeus'
require 'date'

ENV['RACK_ENV'] = 'development' unless ENV['MONGOLAB_URI']

Mongoid.load!("configs/mongoid.yml", ENV['RACK_ENV'])
Dir[File.expand_path('../models/**/*.rb', __FILE__)].each {|f| require f}

desc "One time data transform"
task :transform do
  Keyword.all.each do |k|
    k.unset(:created_at)
    k.unset(:updated_at)
    k.unset(:counts)
    k.stats.each do |s|
      s.update_attribute(:date, s.created_at)
      s.unset(:created_at)
      s.unset(:updated_at)
      s.unset(:count)
      print '.'
    end
    print '.'
  end
  Snapshot.all.each do |sn|
    sn.terms.each do |t|
      t.unset(:count)
      print '.'
    end
  end
  puts 'Done.'
end

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

desc "Backfill missing snapshots dates"
task :backfill_snapshots do
  keyword_dates = Keyword.first.stats.map{|s| s.date}.uniq
  snap_dates = Snapshot.all.map(&:date)
  missing_dates = keyword_dates - snap_dates
  missing_dates.each do |d|
    s = Snapshot.new(date: d)
    Keyword.all.each do |k|
      stat = k.stats.where(date: d).last
      s.terms.build(name: k.name, daily_count: stat.daily_count)
      print '.'
    end
    s.save
  end
  puts 'Done.'
end

desc "Take snapshots for a range of dates. Ex: rake shapshot_range[2012-1-25,2012-1-30]"
task :snapshot_range, :beginning_date, :end_date do |t,args|
  beginning_date = Date.parse(args[:beginning_date])
  end_date = Date.parse(args[:end_date])
  (beginning_date..end_date).each do |d|
    Rake::Task['snapshot'].reenable
    Rake::Task['snapshot'].invoke(d.strftime('%Y-%m-%d'))
  end
end

desc "Take snapshot. Ex: rake shapshot[2012-1-25]"
task :snapshot, :date do |t, args|
  date = Date.parse(args[:date])
  beg_range = date
  end_range = date+1
  puts "Taking snapshot for #{date}"
  hydra = Typhoeus::Hydra.new
  snap = Snapshot.find_or_initialize_by(date: date)
  Keyword.all.each do |k|
    key = Typhoeus::Utils.escape(k.name)
    query = "http://api.thriftdb.com/api.hnsearch.com/items/_search?q=#{key}&limit=0&filter[fields][create_ts]=[#{beg_range}T00:00:00Z%20TO%20#{end_range}T00:00:00Z]"
    req = Typhoeus::Request.new(query)
    req.on_complete do |res|
      hits = JSON.parse(res.body)['hits']
      if snap.persisted?
        t = snap.terms.find_or_initialize_by(name: k.name)
        if t.persisted?
          if t.category
            t.update_attribute(:daily_count, hits)
          else
            t.update_attributes(daily_count: hits, category: k.category)
          end
        else
          t.daily_count = hits
          t.category = k.category
          t.save
        end
      else
        snap.terms.build(name: k.name, category: k.category, daily_count: hits)
        snap.save
      end

      stat = k.stats.where(date: date).first
      if stat
        stat.update_attribute(:daily_count, hits)
      else
        k.stats.create(date: date, daily_count: hits)
      end
      print '*'
    end
    hydra.queue(req)
    print '.'
  end
  hydra.run
  puts 'Done.'
end

def get_total_hits(keyword, date=Date.today)
  query = "http://api.thriftdb.com/api.hnsearch.com/items/_search?q=#{key}&limit=0&filter[fields][create_ts]=[*%20TO%20#{date}T00:00:00Z]"
  res = Typhoeus::Request.get(query)
  JSON.parse(res.body)['hits']
end

# http://api.thriftdb.com/api.hnsearch.com/items/_search?q=chrome&filter[fields][create_ts]=[2012-10-02T00:00:00Z%20TO%202012-10-03T00:00:00Z]
desc "Update keyword stats"
task :update_stats do
  date = Date.today
  hydra = Typhoeus::Hydra.new
  s=Snapshot.new(date: date)
  Keyword.all.each do |k|
    key = Typhoeus::Utils.escape(k.name)
    query = "http://api.thriftdb.com/api.hnsearch.com/items/_search?q=#{key}&limit=0&filter[fields][create_ts]=[#{date-1}T00:00:00Z%20TO%20#{date}T00:00:00Z]"
    request = Typhoeus::Request.new query
    request.on_complete do |response|
      hits = JSON.parse(response.body)['hits']
      s.terms << Term.new(name: k.name, category: k.category, daily_count: hits)
      k.stats << Stat.new(date: date, daily_count: hits)
      print '*'
    end
    hydra.queue(request)
    print '.'
  end
  hydra.run
  s.save
  puts 'Done.'
end
