require 'mongoid'

class Keyword
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :stats

  field :name, type: String
  field :counts, type: Array

  def latest_count
    stats.last.try(:count)
  end

  def trend
    return 0 if stats.size <= 0
    rvals = stats.asc(:count).map(&:count)
    (rvals.last - rvals.first).to_f / rvals.first
  end
end
