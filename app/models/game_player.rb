class GamePlayer < ApplicationRecord
  # Relations
  belongs_to :player
  belongs_to :game

  # Validationss
  validates :player, :game, :victory, :validated, presence: true
  
end
