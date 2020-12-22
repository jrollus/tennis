class GameSet < ApplicationRecord
  belongs_to :game
  has_one :tie_break
end