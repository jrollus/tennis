class TieBreak < ApplicationRecord
  # Relations
  belongs_to :game_set

  # Validations
  validates :game_set, :points_1, :points_2, presence: true
end