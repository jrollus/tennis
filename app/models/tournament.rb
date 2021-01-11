class Tournament < ApplicationRecord
  # Relations
  belongs_to :club
  belongs_to :category
  belongs_to :player, optional: true

  has_many :games
  
  # Validations
  validates :club, :category, :start_date, :end_date, :nbr_participants, presence: true
  validates :club, uniqueness: { scope: [:category, :start_date, :end_date] }

end
