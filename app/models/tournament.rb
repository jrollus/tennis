class Tournament < ApplicationRecord
  # Relations
  belongs_to :club
  belongs_to :category
  belongs_to :player, optional: true

  has_many :games
  
  # Validations
  validates :club, :category, :start_date, :end_date, :nbr_participants, presence: true
  validates :club, uniqueness: { scope: [:category, :start_date, :end_date] }

  # Instance Method
  def name
    "#{self.club.name} - #{start_date} - #{end_date} - #{category.category}"
  end

  def tournament_date
    "#{self.start_date.strftime("%d/%m/%Y")} - #{self.end_date.strftime("%d/%m/%Y")}"
  end

  private

end
