class Keyword
  include Mongoid::Document

  embeds_many :stats

  field :name, type: String
  field :category, type: String

  index({ category: 1 }, { sparse: true })

  validates :name, uniqueness: true

  def self.categories
    all.map(&:category).uniq
  end

  def self.trending(size=10)
    all.sort do |a,b|
      b.trend <=> a.trend
    end[0..size-1]
  end

  def trend
    return 0 if stats.size < 2
    latest = stats.desc(:date).limit(30).to_a
    rvals = latest.map(&:daily_count).compact.sort
    rvals = rvals.drop_while{|i|i<=0}
    return 0 if rvals.empty?
    (rvals.last - rvals.first).to_f / rvals.first
  end
 
  def latest_daily_count
    stats.last.try(:daily_count)
  end
end
