class GameSet < ApplicationRecord
  # Relations
  belongs_to :game
  
  # Nested Attributes
  has_one :tie_break, dependent: :destroy
  accepts_nested_attributes_for :tie_break, allow_destroy: true

  # Validations
  validates :game, :set_number, :games_1, :games_1, presence: true
end