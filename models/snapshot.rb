class Snapshot
  include Mongoid::Document

  embeds_many :terms

  field :date, type: Date
end
