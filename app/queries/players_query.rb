class PlayersQuery
  def initialize(player)
      @player = player
  end
  
  def get_nbr_games
    @player.game_players.count
  end

  def get_nbr_wins_losses(win, year=nil)
    if year
      query = 'game_players.victory = ? AND extract(year from games.date) = ?'
      @player.game_players.joins(:game).where(query, win, year).count
    else
      query = 'game_players.victory = ?'
      @player.game_players.joins(:game).where(query, win).count
    end
  end

  def get_win_ratio(win, year=nil)
    @player.get_nbr_wins_losses(win, year) / self.get_nbr_games
  end

  def get_wins_losses_by_tournament(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win, year).group('categories.category').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win).group('categories.category').count
    end
  end

  def get_wins_losses_dominant_hand(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, win, year)})
                                        .where.not(game_players: {player_id: @player.id}).group(:dominant_hand).count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, win)})
                                        .where.not(game_players: {player_id: @player.id}).group(:dominant_hand).count
    end
  end
  
  def get_wins_losses_by_court_type(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      Game.joins(:game_players, :court_type).where(query, @player.id, win, year).group('court_types.court_type').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      Game.joins(:game_players, :court_type).where(query, @player.id, win).group('court_types.court_type').count
    end
  end

  def get_wins_by_ranking(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      player_subset = GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, win, year)})
                                                                                          .where.not(game_players: {player_id: @player.id})
                                                                                          .group('rankings.name').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      player_subset = GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, win, year)})
                                                                                          .where.not(game_players: {player_id: @player.id})
                                                                                          .group('rankings.name').count
    end
  end

  def get_match_points(win, year=nil)
    if year
      query = (win ? 'game_players.player_id = ? AND  match_points_saved > ? AND extract(year from games.date) = ?' : 'game_players.player_id = ? AND  match_points_saved < ? AND extract(year from games.date) = ?')
      GamePlayer.joins(:game).where(query, @player.id, 0, year).sum(:match_points_saved)
    else
      query = (win ? 'game_players.player_id = ? AND  match_points_saved > ?' : 'game_players.player_id = ? AND  match_points_saved < ?')
      GamePlayer.joins(:game).where(query, @player.id, 0).sum(:match_points_saved)
    end
  end

  def get_wins_losses_nbr_sets(win, nbr_sets, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      GamePlayer.joins(game: :game_sets).where(query, @player.id, win, year).group('games.id').having('count(games.id) = ?', nbr_sets).count.count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      GamePlayer.joins(game: :game_sets).where(query, @player.id, win).group('games.id').having('count(games.id) = ?', nbr_sets).count.count
    end
  end

  def get_rounds_won_lost(win, round, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ? AND games.round = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win, year, round).group('categories.category').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ? AND games.round = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win, round).group('categories.category').count
    end
  end
end
  