class GamePlayerOrderService
  def self.maintain?(game, player_id)
    victory = game.game_players.find{|player| player.player_id == player_id}.victory
    sets_won = 0
    game.game_sets.each do |set|
      sets_won += (set.games_1 > set.games_2) ? 1 : 0
    end
    if victory
      return (sets_won == 2 ? true : false)
    else
      return (sets_won == 2 ? false : true)
    end
  end  
end