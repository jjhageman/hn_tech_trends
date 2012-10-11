require 'mongoid'
require 'debugger'

class Keyword
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :stats

  field :name, type: String
  field :category, type: String
  field :counts, type: Array

  index({ category: 1 }, { sparse: true })

  validates :name, uniqueness: true

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
