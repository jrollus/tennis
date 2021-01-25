class PlayerPointsQuery
    def initialize(games, player)
      @games = games
      @player = player
    end
  
    def get_games(start_date=nil, end_date=nil)
      if start_date && end_date
        query = 'game_players.player_id = ? AND (games.date BETWEEN ? AND ?)'
        games = @games.includes(:round, game_players: :ranking, tournament: {category: :category_rounds})
                      .joins(:game_players, :tournament).where(query, @player.id, start_date, end_date).order('tournaments.start_date DESC, games.round_id DESC')
                      .group_by(&:tournament_id)
      else
        query = 'game_players.player_id = ?'
        games = @games.includes(:round, game_players: :ranking, tournament: {category: :category_rounds})
                      .joins(:game_players, :tournament).where(query, @player.id).order('tournaments.start_date DESC, games.round_id DESC')
                      .group_by(&:tournament_id)
      end
    end
  end