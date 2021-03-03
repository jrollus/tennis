class PlayerGamesQuery
  def initialize(games, player)
    @games = games
    @player = player
  end

  def get_tournament_games(year=nil)
    if year
      query = 'game_players.player_id = ? AND games.interclub_id IS NULL AND extract(year from games.date) = ?'
      games = @games.includes(:round, players: :ranking_histories, game_players: :ranking, game_sets: :tie_break, tournament: [:club, :category])
                    .joins(:game_players, :tournament).where(query, @player.id, year).order('tournaments.start_date DESC, games.round_id DESC')
                    .group_by(&:tournament_id)
    else
      query = 'game_players.player_id = ? AND games.interclub_id IS NULL'
      games = @games.includes(:round, players: :ranking_histories, game_players: :ranking, game_sets: :tie_break, tournament: [:club, :category])
                    .joins(:game_players, :tournament).where(query, @player.id).order('tournaments.start_date DESC, games.round_id DESC')
                    .group_by(&:tournament_id)
    end
  end

  def get_interclub_games(year=nil)
    if year
      query = 'game_players.player_id = ? AND games.tournament_id IS NULL AND extract(year from games.date) = ?'
      games = @games.includes(interclub: :division, players: :ranking_histories, game_players: :ranking, game_sets: :tie_break)
                    .joins(:game_players, :interclub).where(query, @player.id, year).order('games.date DESC')
                    .group_by(&:interclub_id)
    else
      query = 'game_players.player_id = ? AND games.tournament_id IS NULL'
      games = @games.includes(interclub: :division, players: :ranking_histories, game_players: :ranking, game_sets: :tie_break)
                    .joins(:game_players, :interclub).where(query, @player.id).order('games.date DESC')
                    .group_by(&:interclub_id)
    end
  end
end