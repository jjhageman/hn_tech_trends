require 'mongoid'

class Stat
  include Mongoid::Document
  include Mongoid::Timestamps  

  embedded_in :keyword
  field :date, type: Date
  field :daily_count, type: Integer
end
