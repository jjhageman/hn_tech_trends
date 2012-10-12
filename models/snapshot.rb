class Snapshot
  include Mongoid::Document

  embeds_many :terms
  index "terms.category" => 1

  field :date, type: Date

  def self.to_chart(snapshots, category)
    snapshots.collect do |snap|
      h = {date: snap.date}
      snap.terms.where(category: category).each {|t| h[t.name] = t.daily_count }
      h
    end
  end

  def self.names_and_categories
    term_names=[]
    categories=[]
    last.terms.collect do |t|
      term_names << t.name
      categories << t.category
    end
    [term_names, categories.uniq]
  end
end
