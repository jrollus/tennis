class GamePlayer < ApplicationRecord
  # Relations
  belongs_to :player
  belongs_to :game

  # Validationss
  validates :player, :game, presence: true
  validates :victory, :validated, inclusion: { in: [ "0", "1", true, false ] }

end
