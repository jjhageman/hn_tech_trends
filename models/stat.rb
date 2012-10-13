class Stat
  include Mongoid::Document

  embedded_in :keyword
  field :date, type: Date
  field :daily_count, type: Integer
end
