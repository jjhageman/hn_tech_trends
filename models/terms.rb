class Term
  include Mongoid::Document

  embedded_in :snapshot

  field :name, type: String
  field :count, type: Integer
  field :daily_count, type: Integer
end
