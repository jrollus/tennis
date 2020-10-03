class Player < ApplicationRecord
  belongs_to :club
  has_many :game_players
  has_many :games, through: :game_players
  has_many :ranking_histories
end
