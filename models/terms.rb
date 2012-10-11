class Term
  include Mongoid::Document

  embedded_in :snapshot

  field :name, type: String
  field :category, type: String
  field :count, type: Integer
  field :daily_count, type: Integer

  validates :name, uniqueness: true
end
