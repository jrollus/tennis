class Game < ApplicationRecord
  belongs_to :tournament
  has_many :game_players
  has_many :players, through: :game_players
  has_many :game_sets
end
