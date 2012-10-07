require 'mongoid'

class Stat
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  embedded_in :keyword
  field :count, type: Integer
  field :daily_count, type: Integer
end
