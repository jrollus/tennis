class RankingHistory < ApplicationRecord
  # Relations
  belongs_to :ranking
  belongs_to :player

  # Validations
  validates :ranking, :player, :year, :year_number, presence: true
  validates :player_id, uniqueness: { scope: [:year, :year_number] }

  # Class Methods
  def self.get_year_nbr_dates
    rankings_per_year = 2 # May get modified later on
    case rankings_per_year
    when 1
      year_number = 1
      start_date = Date.new(Date.today.year, 1, 1)
      end_date = Date.new(Date.today.year, 12, -1)
    when 2
      year_number = (Date.today.month / 6.0).ceil
      start_date = Date.new(Date.today.year, year_number + (5 * (year_number - 1)), 1) 
      end_date = Date.new(Date.today.year, 6 * year_number, -1)
    when 4
      year_number = (Date.today.month / 3.0).ceil
      start_date = Date.new(Date.today.year, year_number + (2 * (year_number - 1)), 1) 
      end_date = Date.new(Date.today.year, 3 * year_number, -1)
    end
    
    return {
      year_number: year_number,
      start_date: start_date,
      end_date: end_date
    }
  end

end
