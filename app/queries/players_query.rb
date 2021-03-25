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
    if win
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win, year).group('categories.category').count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win).group('categories.category').count
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        raw_db_output = GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, year)
                                  .group('categories.category', 'game_players.victory').count
      else
        query = 'game_players.player_id = ?'
        raw_db_output = GamePlayer.joins(game: {tournament: :category}).where(query, @player.id)
                                  .group('categories.category', 'game_players.victory').count
      end
      structured_output = raw_db_output.each_with_object({}) do |((category, win_loss), win_loss_count), hash|
        hash[category] ||= { true => 0, false => 0 }
        hash[category][win_loss] = win_loss_count
      end
      return structured_output
    end
  end

  def get_wins_losses_by_court_type(win, year=nil)
    if win
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        Game.joins(:game_players, :court_type).where(query, @player.id, win, year).group('court_types.court_type').count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        Game.joins(:game_players, :court_type).where(query, @player.id, win).group('court_types.court_type').count
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        raw_db_output = Game.joins(:game_players, :court_type).where(query, @player.id, year).group('court_types.court_type', 'game_players.victory').count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        raw_db_output = Game.joins(:game_players, :court_type).where(query, @player.id, win).group('court_types.court_type', 'game_players.victory').count
      end
      structured_output = raw_db_output.each_with_object({}) do |((category, win_loss), win_loss_count), hash|
        category = category.titleize
        hash[category] ||= { true => 0, false => 0 }
        hash[category][win_loss] = win_loss_count
      end
      return structured_output
    end
  end

  def get_wins_losses_dominant_hand(win, year=nil)
    if win
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, win, year)})
                                          .where.not(game_players: {player_id: @player.id}).group(:dominant_hand).count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, win)})
                                          .where.not(game_players: {player_id: @player.id}).group(:dominant_hand).count
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        raw_db_output = Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, year)})
                                          .where.not(game_players: {player_id: @player.id}).group(:dominant_hand, 'game_players.victory')
                                          .having('players.dominant_hand IS NOT NULL').count
      else
        query = 'game_players.player_id = ?'
        raw_db_output = Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id)})
                                          .where.not(game_players: {player_id: @player.id}).group(:dominant_hand, 'game_players.victory')
                                          .having('players.dominant_hand IS NOT NULL').count
      end
      structured_output = raw_db_output.each_with_object({}) do |((category, win_loss), win_loss_count), hash|
        category = (category == 'left-handed' ? 'Gaucher' : 'Droitier')
        hash[category] ||= { true => 0, false => 0 }
        hash[category][win_loss] = win_loss_count
      end
    
      return structured_output
    end
  end

  def get_wins_losses_indoor(win, year=nil)
    if win
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        Game.joins(:game_players).where(query, @player.id, win, year).group(:indoor).count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        Game.joins(:game_players).where(query, @player.id, win).group(:indoor).count
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        raw_db_output = Game.joins(:game_players).where(query, @player.id, year).group(:indoor, 'game_players.victory')
                            .having('games.indoor IS NOT NULL').count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        raw_db_output = Game.joins(:game_players).where(query, @player.id, win).group(:indoor, 'game_players.victory')
                            .having('games.indoor IS NOT NULL').count
      end
      structured_output = raw_db_output.each_with_object({}) do |((category, win_loss), win_loss_count), hash|
        category = category ? 'Indoor' : 'Outdoor'
        hash[category] ||= { true => 0, false => 0 }
        hash[category][win_loss] = win_loss_count
      end
      return structured_output
    end
  end
  
  def get_wins_losses_nbr_sets(win, nbr_sets, year=nil)
    if win && nbr_sets
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        GamePlayer.joins(game: :game_sets).where(query, @player.id, win, year).group('games.id').having('count(games.id) = ?', nbr_sets).count.count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        GamePlayer.joins(game: :game_sets).where(query, @player.id, win).group('games.id').having('count(games.id) = ?', nbr_sets).count.count
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        raw_db_output = GamePlayer.joins(game: :game_sets).where(query, @player.id, year).group('games.id', 'game_players.victory').count
        structured_output = raw_db_output.each_with_object({}) do |((id, win_loss), nbr_sets), hash|
          nbr_sets = "#{nbr_sets} Sets"
          hash[nbr_sets] ||= { true => 0, false => 0 }
          hash[nbr_sets][win_loss] += 1
        end
        return structured_output
      else
        query = 'game_players.player_id = ?'
        GamePlayer.joins(game: :game_sets).where(query, @player.id).group('games.id').having('count(games.id) = ?', nbr_sets).count.count
      end
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
      player_subset = GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, win)})
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
  