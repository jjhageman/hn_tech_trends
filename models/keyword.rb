require 'mongoid'

class Keyword
  include Mongoid::Document

  embeds_many :stats

  field :name, :type => String
end
