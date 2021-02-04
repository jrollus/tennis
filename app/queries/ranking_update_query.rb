class RankingUpdateQuery
    def initialize(player, ranking_history)
      @player = player
      @ranking_history = ranking_history
    end
  
    def get_games
        query = 'game_players.player_id = ? AND (games.date BETWEEN ? AND ?)'
        game_players = GamePlayer.joins(:game).where(query, @player.id, @ranking_history.start_date, @ranking_history.end_date)
    end
  end