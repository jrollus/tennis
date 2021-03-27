class RankingUpdateQuery
    def initialize(player, ranking_history)
      @player = player
      @ranking_history = ranking_history
    end
  
    def get_player_games
      query = 'game_players.player_id = ? AND (games.date BETWEEN ? AND ?)'
      game_players = GamePlayer.joins(:game).where(query, @player.id, @ranking_history.start_date, @ranking_history.end_date)
    end

    def get_opponents
      query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
      player_subset = Player.joins(game_players: :game)
                            .where(games: {id: Game.joins(:game_players).where(query, @player.id, @ranking_history.end_date.year)})
                            .where.not(game_players: {player_id: @player.id})
      
    end
  end