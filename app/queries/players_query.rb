class PlayersQuery
  def initialize(player)
      @player = player
  end
  
  def get_nbr_games
    @player.game_players.count
  end

  def get_nbr_wins_losses(win, year=nil)
    unless win.nil?
      if year
        query = 'game_players.victory = ? AND extract(year from games.date) = ?'
        @player.game_players.joins(:game).where(query, win, year).count
      else
        query = 'game_players.victory = ?'
        @player.game_players.joins(:game).where(query, win).count
      end
    else
      if year
        query = 'extract(year from games.date) = ?'
        raw_db_output = @player.game_players.joins(:game).where(query, year)
                            .group('game_players.victory').count
      else
        raw_db_output = @player.game_players.joins(:game).group('game_players.victory').count
      end
      return raw_db_output
    end
    
  end

  def get_win_ratio(win, year=nil)
    @player.get_nbr_wins_losses(win, year) / self.get_nbr_games
  end

  def get_wins_losses_by(type, win, year=nil)
    unless win.nil?
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        case type
        when 'tournament'
          GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win, year).group('categories.category').count
        when 'court_type'
          Game.joins(:game_players, :court_type).where(query, @player.id, win, year).group('court_types.court_type').count
        when 'dominant_hand'
          Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, win, year)})
                .where.not(game_players: {player_id: @player.id}).group(:dominant_hand).count
        when 'indoor'
          Game.joins(:game_players).where(query, @player.id, win, year).group(:indoor).count
        end
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        case type
        when 'tournament'
          GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, win).group('categories.category').count
        when 'court_type'
          Game.joins(:game_players, :court_type).where(query, @player.id, win).group('court_types.court_type').count
        when 'dominant_hand'
          Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, win)})
                .where.not(game_players: {player_id: @player.id}).group(:dominant_hand).count
        when 'indoor'
          Game.joins(:game_players).where(query, @player.id, win).group(:indoor).count
        end
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        case type
        when 'tournament'
          raw_db_output = GamePlayer.joins(game: {tournament: :category}).where(query, @player.id, year)
                                    .group('categories.category', 'game_players.victory', 'categories.id')
                                    .order('categories.id ASC').count
        when 'court_type'
          raw_db_output = Game.joins(:game_players, :court_type).where(query, @player.id, year)
                              .group('court_types.court_type', 'game_players.victory').count
        when 'dominant_hand'
          raw_db_output = Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id, year)})
                                .where.not(game_players: {player_id: @player.id}).group(:dominant_hand, 'game_players.victory')
                                .having('players.dominant_hand IS NOT NULL').count
        when 'indoor'
          raw_db_output = Game.joins(:game_players).where(query, @player.id, year).group(:indoor, 'game_players.victory')
                              .having('games.indoor IS NOT NULL').count
        end
      else
        query = 'game_players.player_id = ?'
        case type
        when 'tournament'
          raw_db_output = GamePlayer.joins(game: {tournament: :category}).where(query, @player.id)
                                    .group('categories.category', 'game_players.victory', 'categories.id')
                                    .order('categories.id ASC').count
        when 'court_type'
          raw_db_output = Game.joins(:game_players, :court_type).where(query, @player.id)
                              .group('court_types.court_type', 'game_players.victory').count
        when 'dominant_hand'
          raw_db_output = Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, @player.id)})
                                .where.not(game_players: {player_id: @player.id}).group(:dominant_hand, 'game_players.victory')
                                .having('players.dominant_hand IS NOT NULL').count
        when 'indoor'
          raw_db_output = Game.joins(:game_players).where(query, @player.id).group(:indoor, 'game_players.victory')
                               .having('games.indoor IS NOT NULL').count
        end
      end
      structured_output = raw_db_output.each_with_object({}) do |((category, win_loss), win_loss_count), hash|
        case type
        when 'dominant_hand'
          category = (category == 'left-handed' ? 'Gaucher' : 'Droitier')
        when 'indoor'
          category = category ? 'Indoor' : 'Outdoor'
        end
        category = category.titleize
        hash[category] ||= { true => 0, false => 0 }
        hash[category][win_loss] = win_loss_count
      end
      return structured_output
    end
  end

  def get_wins_losses_nbr_sets(win, nbr_sets, year=nil)
    unless win.nil? && nbr_sets.nil?
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
        
      else
        query = 'game_players.player_id = ?'
        raw_db_output = GamePlayer.joins(game: :game_sets).where(query, @player.id).group('games.id', 'game_players.victory').count
      end
      structured_output = raw_db_output.each_with_object({}) do |((id, win_loss), nbr_sets), hash|
        if nbr_sets != 1
          nbr_sets = "#{nbr_sets} Sets"
          hash[nbr_sets] ||= { true => 0, false => 0 }
          hash[nbr_sets][win_loss] += 1
        end
      end
      return structured_output
    end
  end

  def get_wins_losses_tie_breaks(win, year=nil)
    unless win.nil?
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        GamePlayer.joins(game: {game_sets: :tie_break}).where(query, @player.id, win, year).count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        GamePlayer.joins(game: {game_sets: :tie_break}).where(query, @player.id, win).count
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        raw_db_output = GamePlayer.joins(game: {game_sets: :tie_break}).where(query, @player.id, year).group('game_players.victory').count
      else
        query = 'game_players.player_id = ?'
        raw_db_output = GamePlayer.joins(game: {game_sets: :tie_break}).where(query, @player.id).group('game_players.victory').count
      end
      structured_output = raw_db_output.each_with_object({}) do |(win_loss, win_loss_count), hash|
        hash['Tie-Break'] ||= { true => 0, false => 0 }
        hash['Tie-Break'][win_loss] = win_loss_count
      end
      return structured_output
    end
  end

  def get_match_points(win, year=nil)
    if year
      query = (win ? 'game_players.player_id = ? AND  match_points_saved > ? AND extract(year from games.date) = ?' : 
                     'game_players.player_id = ? AND  match_points_saved < ? AND extract(year from games.date) = ?')
      GamePlayer.joins(:game).where(query, @player.id, 0, year).sum(:match_points_saved)
    else
      query = (win ? 'game_players.player_id = ? AND  match_points_saved > ?' : 'game_players.player_id = ? AND  match_points_saved < ?')
      GamePlayer.joins(:game).where(query, @player.id, 0).sum(:match_points_saved)
    end
  end

  def get_tournament_won(year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ? AND rounds.id = ?'
      Game.joins(:game_players, :round).includes(tournament: [:club, :category]).where(query, @player.id, true, year, 2)
          .order('tournaments.start_date DESC')
    else
      query = 'game_players.player_id = ? AND game_players.victory = ? AND rounds.id = ?'
      Game.joins(:game_players, :round).includes(tournament: [:club, :category]).where(query, @player.id, true, 2).order('tournaments.start_date DESC')
    end
  end

  def get_wins_by_ranking(win, year=nil)
    unless win.nil?
      if year
        query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
        raw_db_output = GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, win, year)})
                                                                                            .where.not(game_players: {player_id: @player.id})
                                                                                            .group('rankings.name', 'rankings.id')
                                                                                            .order('rankings.id ASC').count
      else
        query = 'game_players.player_id = ? AND game_players.victory = ?'
        raw_db_output = GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, win)})
                                                                                            .where.not(game_players: {player_id: @player.id})
                                                                                            .group('rankings.name', 'rankings.id')
                                                                                            .order('rankings.id ASC').count
      end
      structured_output = raw_db_output.each_with_object({}) do |((ranking, id), win_loss_count), hash|
        hash[ranking] ||= win_loss_count
      end
    else
      if year
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        raw_db_output = GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, year)})
                                                                                            .where.not(game_players: {player_id: @player.id})
                                                                                            .group('rankings.name', 'rankings.id', 'game_players.victory')
                                                                                            .order('rankings.id ASC').count
      else
        query = 'game_players.player_id = ?'
        raw_db_output = GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id)})
                                                                                            .where.not(game_players: {player_id: @player.id})
                                                                                            .group('rankings.name', 'rankings.id', 'game_players.victory')
                                                                                            .order('rankings.id ASC').count
      end
      
      structured_output = raw_db_output.each_with_object({}) do |((ranking, id, win_loss), win_loss_count), hash|
        hash[ranking] ||= { true => 0, false => 0 }
        hash[ranking][!win_loss] = win_loss_count
      end
    end
    return structured_output
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

  def get_head_to_head(other_player, win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, win, year)})
                                                       .where(game_players: {player_id: other_player.id})
                                                       .count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      GamePlayer.joins(:game, :ranking).where(games: {id: Game.joins(:game_players).where(query, @player.id, win)})
                                                       .where(game_players: {player_id: other_player.id})
                                                       .count
    end
  end
end
  