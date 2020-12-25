class Game < ApplicationRecord
  belongs_to :tournament
  has_many :game_players
  has_many :players, through: :game_players

  # Nested attributes
  has_many :game_sets
  accepts_nested_attributes_for :game_sets, allow_destroy: true

  def check_user_order(player_id)
    victory = self.game_players.where(player_id: player_id).first.victory
    sets_won = 0
    self.game_sets.each do |set|
      sets_won += (set.games_1 > set.games_2) ? 1 : 0
    end
    (sets_won == 2) ? true : false
  end
end
