class Game < ApplicationRecord
  # Relations
  belongs_to :tournament
  belongs_to :court_type, optional: true
  belongs_to :player, optional: true
  belongs_to :round
  has_many :game_players, dependent: :destroy
  has_many :players, through: :game_players
  
  # Nested attributes
  has_many :game_sets, dependent: :destroy
  accepts_nested_attributes_for :game_sets, allow_destroy: true

  # Instance Methods
  def check_user_order(player_id)
    victory = self.game_players.find{|player| player.player_id == player_id}.victory
    sets_won = 0
    self.game_sets.each do |set|
      sets_won += (set.games_1 > set.games_2) ? 1 : 0
    end
    if victory
      return (sets_won == 2 ? true : false)
    else
      return (sets_won == 2 ? false : true)
    end
  end

  def game_score(player_id)
    user_order = (self.player_id ? (self.player_id == player_id) : check_user_order(player_id))
    score = ""
    self.game_sets.each do |set|
      score += (user_order ? "#{set.games_1}/#{set.games_2} " : "#{set.games_2}/#{set.games_1} ")
      score += (user_order ? "(#{set.tie_break.points_1}/#{set.tie_break.points_2}) " : "(#{set.tie_break.points_1}/#{set.tie_break.points_2} )") if set.tie_break
    end
    return score
  end
  
end