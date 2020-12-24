class GameSet < ApplicationRecord
  belongs_to :game
  
  # Nested Attributes
  has_one :tie_break
  accepts_nested_attributes_for :tie_break
end