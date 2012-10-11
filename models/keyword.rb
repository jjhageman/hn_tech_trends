require 'mongoid'
require 'debugger'

class Keyword
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :stats

  field :name, type: String
  field :counts, type: Array

  #def self.to_chart(keywords)
    #dates = keywords.first.stats.map{|s| s.created_at}.uniq
    #dates.collect do |date|
      #h = {date: date.strftime('%Y-%m-%d')}
      #keywords.each do |k|
        #h[k.name] = k.stats.detect { |s| s.created_at.to_date == date.to_date }.try(:count)
      #end
      #h
    #end
  #end

  def self.trending(size=10)
    all.sort{|a,b| b.trend <=> a.trend}[0..size-1]
  end

  def trend
    return 0 if stats.size <= 0
    rvals = stats.asc(:daily_count).map(&:daily_count)
    rvals = rvals.drop_while{|i|i<=0}
    (rvals.last - rvals.first).to_f / rvals.first
  end
 
  def latest_daily_count
    stats.last.try(:daily_count)
  end
end
