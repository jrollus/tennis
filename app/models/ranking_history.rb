class RankingHistory < ApplicationRecord
  # Relations
  belongs_to :ranking
  belongs_to :player

  # Validations
  validates :ranking, :player, :year, :year_number, presence: true
  validates :player_id, uniqueness: { scope: [:year, :year_number] }

  # Class Methods
  def self.get_year_number
    rankings_per_year = 2 # May get modified later on
    case rankings_per_year
    when 1
      year_number = 1
    when 2
      year_number = (Date.today.month / 6.0).ceil
    when 4
      year_number = (Date.today.month / 3.0).ceil
    end
    
    return year_number
  end

end