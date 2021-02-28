class Game < ApplicationRecord
  # Relations
  belongs_to :interclub, optional: true
  belongs_to :tournament, optional: true
  belongs_to :court_type, optional: true
  belongs_to :player, optional: true
  belongs_to :round
  has_many :game_players, dependent: :destroy
  has_many :players, through: :game_players

  # Nested attributes
  has_many :game_sets, dependent: :destroy
  accepts_nested_attributes_for :game_sets, allow_destroy: true
  
end