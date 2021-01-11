class RankingHistory < ApplicationRecord
  # Relations
  belongs_to :ranking
  belongs_to :player

  # Validations
  validates :ranking, :player, :year, :year_number, presence: true
  validates :player_id, uniqueness: { scope: [:year, :year_number] }

end
