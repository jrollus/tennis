class GameDecorator < SimpleDelegator
  def model
    __getobj__
  end

  def game_score(player_id)
    user_order = (self.player_id ? (self.player_id == player_id) : GamePlayerOrderService.maintain?(self, player_id))
    score = ""
    self.game_sets.each do |set|
      score += (user_order ? "#{set.games_1}/#{set.games_2} " : "#{set.games_2}/#{set.games_1} ")
      score += (user_order ? "(#{set.tie_break.points_1}/#{set.tie_break.points_2}) " : "(#{set.tie_break.points_1}/#{set.tie_break.points_2} )") if set.tie_break
    end
    return score
  end
end