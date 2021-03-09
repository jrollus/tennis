class PlayerPointsQuery
    def initialize(games, player)
      @games = games
      @player = player
    end
  
    def get_tournament_games(start_date=nil, end_date=nil)
      if start_date && end_date
        query = 'game_players.player_id = ? AND games.interclub_id IS NULL AND (games.date BETWEEN ? AND ?)'
        games = @games.includes(:round, game_players: :ranking, tournament: {category: :category_rounds})
                      .joins(:game_players, :tournament).where(query, @player.id, start_date, end_date).order('tournaments.start_date DESC, games.round_id DESC')
                      .group_by(&:tournament_id)
      else
        query = 'game_players.player_id = ? AND games.interclub_id IS NULL'
        games = @games.includes(:round, game_players: :ranking, tournament: {category: :category_rounds})
                      .joins(:game_players, :tournament).where(query, @player.id).order('tournaments.start_date DESC, games.round_id DESC')
                      .group_by(&:tournament_id)
      end
    end

    def get_interclub_games(start_date=nil, end_date=nil)
      if start_date && end_date
        query = 'game_players.player_id = ? AND games.tournament_id IS NULL AND (games.date BETWEEN ? AND ?)'
        games = @games.includes(interclub: {division: :division_rankings}, game_players: :ranking)
                      .joins(:game_players, :interclub).where(query, @player.id, start_date, end_date)
                      .group_by(&:interclub_id)
      else
        query = 'game_players.player_id = ? AND games.tournament_id IS NULL'
        games = @games.includes(interclub: {division: :division_rankings}, game_players: :ranking)
                      .joins(:game_players, :interclub).where(query, @player.id)
                      .group_by(&:interclub_id)
      end
    end
  end