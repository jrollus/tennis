class Tournament < ApplicationRecord
  # Relations
  belongs_to :club
  belongs_to :category
  has_many :games
  
  # Validations
  validates :club, :category, :start_date, :end_date, :nbr_participants, presence: true
  validates :club, uniqueness: { scope: [:category, :start_date, :end_date] }

  private

  def name
    "#{club.name} - #{start_date} - #{end_date} - #{category.category}"
  end

  def tournament_date
    "#{start_date} - #{end_date}"
  end
end
