class Tournament < ApplicationRecord
  # Relations
  belongs_to :club
  belongs_to :category
  belongs_to :player, optional: true
  has_many :games
  
  # Validations
  validates :club, :category, :start_date, :end_date, :nbr_participants, presence: true
  validates :club, uniqueness: { scope: [:category, :start_date, :end_date] }
  validates :nbr_participants, numericality: { only_integer: true }
  validate :valid_date

  private

  def valid_date
    unless self.start_date.blank? || self.end_date.blank?
      errors.add(:end_date, 'doit être postérieure à la date de début') unless self.end_date > self.start_date
    end
  end
  
end
