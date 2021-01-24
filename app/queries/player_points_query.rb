class PlayerPointsQuery
    def initialize(games, player)
      @games = games
      @player = player
    end
  
    def get_games(year=nil)
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        games = @games.includes(:round, game_players: :ranking, tournament: {category: :category_rounds})
                      .joins(:game_players, :tournament).where(query, @player.id, year).order('tournaments.start_date DESC, games.round_id DESC')
                      .group_by(&:tournament_id)
      else
        query = 'game_players.player_id = ?'
        games = @games.includes(:round, game_players: :ranking, tournament: {category: :category_rounds})
                      .joins(:game_players, :tournament).where(query, @player.id).order('tournaments.start_date DESC, games.round_id DESC')
                      .group_by(&:tournament_id)
      end
    end
  end