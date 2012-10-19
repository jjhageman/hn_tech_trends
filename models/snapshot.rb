class Snapshot
  include Mongoid::Document

  embeds_many :terms
  index "terms.category" => 1

  field :date, type: Date

  def self.to_chart(category)
    term_names=[]
    chart_data=[]
    all.desc(:date).limit(30).collect do |snap|
      h = {date: snap.date}
      snap.terms.where(category: category).each do |t|
        term_names << t.name
        h[t.name] = t.daily_count
      end
      h
    end
    [term_names.uniq, chart_data]
  end
end
