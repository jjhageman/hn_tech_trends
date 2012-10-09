class Snapshot
  include Mongoid::Document

  embeds_many :terms

  field :date, type: Date

  def self.to_chart(snapshots)
    snapshots.collect do |snap|
      h = {date: snap.date}
      snap.terms.each {|t| h[t.name] = t.daily_count }
      h
    end
  end
end
