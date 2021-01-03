class Player < ApplicationRecord
  # Relations
  belongs_to :user, optional: true
  belongs_to :club
  has_many :game_players
  has_many :games, through: :game_players
  has_many :tournaments, through: :games
  has_many :categories, through: :tournaments
  has_many :ranking_histories
  has_many :ranking, through: :ranking_histories

  # Nested attributes
  accepts_nested_attributes_for :ranking_histories

  # Validations
  validates :club, :affiliation_number, :gender, :first_name, :last_name, presence: true
  validate :affiliation_number_check
  
  # PG Search
  include PgSearch::Model
  pg_search_scope :search_by_name_and_affiliation_number,
    against: [:first_name, :last_name, :affiliation_number],
    using: {
      tsearch: { prefix: true }
  }
  
  # Instance Methods
  def get_age
    Date.today.year - self.birthdate.year
  end

  def get_nbr_games
    self.game_players.count
  end

  def get_nbr_wins_losses(win, year=nil)
    if year
      query = 'game_players.victory = ? AND extract(year from games.date) = ?'
      self.game_players.joins(:game).where(query, win, year).count
    else
      query = 'game_players.victory = ?'
      self.game_players.joins(:game).where(query, win).count
    end
  end

  def get_win_ratio(win, year=nil)
    self.get_nbr_wins_losses(win, year) / self.get_nbr_games
  end

  def get_wins_losses_by_tournament(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, self.id, win, year).group('categories.category').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, self.id, win).group('categories.category').count
    end
  end


  def get_wins_losses_dominant_hand(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, self.id, win, year)})
                                       .where.not(game_players: {player_id: self.id}).group(:dominant_hand).count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      Player.joins(game_players: :game).where(games: {id: Game.joins(:game_players).where(query, self.id, win)})
                                       .where.not(game_players: {player_id: self.id}).group(:dominant_hand).count
    end
  end

  
  def get_wins_losses_by_court_type(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      Game.joins(:game_players, :court_type).where(query, self.id, win, year).group('court_types.court_type').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      Game.joins(:game_players, :court_type).where(query, self.id, win).group('court_types.court_type').count
    end
  end

  def get_wins_by_ranking(win, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      player_subset = Player.joins(game_players: :game,ranking_histories: :ranking).where(games: {id: Game.joins(:game_players).where(query, self.id, win, year)})
                                                                                  .where.not(game_players: {player_id: self.id})
      Ranking.joins(ranking_histories: :player).where(players: {id:  player_subset}, ranking_histories: {year: year, year_number: RankingHistory.select('MAX(year_number)')}).group('rankings.name').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      player_subset = Player.joins(game_players: :game,ranking_histories: :ranking).where(games: {id: Game.joins(:game_players).where(query, self.id, win)})
                                                                                  .where.not(game_players: {player_id: self.id})
      Ranking.joins(ranking_histories: :player).where(players: {id:  player_subset}).group('rankings.name').count
    end
  end


  def get_match_points(win, year=nil)
    if year
      query = (win ? 'game_players.player_id = ? AND  match_points_saved > ? AND extract(year from games.date) = ?' : 'game_players.player_id = ? AND  match_points_saved < ? AND extract(year from games.date) = ?')
      GamePlayer.joins(:game).where(query, self.id, 0, year).sum(:match_points_saved)
    else
      query = (win ? 'game_players.player_id = ? AND  match_points_saved > ?' : 'game_players.player_id = ? AND  match_points_saved < ?')
      GamePlayer.joins(:game).where(query, self.id, 0).sum(:match_points_saved)
    end
  end

  def get_wins_losses_nbr_sets(win, nbr_sets, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ?'
      GamePlayer.joins(game: :game_sets).where(query, self.id, win, year).group('games.id').having('count(games.id) = ?', nbr_sets).count.count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ?'
      GamePlayer.joins(game: :game_sets).where(query, self.id, win).group('games.id').having('count(games.id) = ?', nbr_sets).count.count
    end
  end

  def get_rounds_won_lost(win, round, year=nil)
    if year
      query = 'game_players.player_id = ? AND game_players.victory = ? AND extract(year from games.date) = ? AND games.round = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, self.id, win, year, round).group('categories.category').count
    else
      query = 'game_players.player_id = ? AND game_players.victory = ? AND games.round = ?'
      GamePlayer.joins(game: {tournament: :category}).where(query, self.id, win, round).group('categories.category').count
    end
  end

  def full_name
    "#{self.first_name.capitalize} #{self.last_name.capitalize}"
  end
  
  private 

  # Custom Validations
  def affiliation_number_check
    player = Player.find_by_affiliation_number(self.affiliation_number)
    # Created through nested attributes
    if self.user
      if player
          errors.add(:affiliation_number, "Déjà associé à un autre e-mail") if (!player.user_id.nil? && (player.user.email != self.user.email))
      end
    # Create as a stand-alone player
    else
      errors.add(:affiliation_number, "Déjà existant") if player
    end
  end


  # def wins_by_ranking
  #   query = <<-SQL
  #     SELECT games.id FROM games
  #     JOIN game_players ON game_players.game_id = games.id
  #     JOIN players ON players.id = game_players.player_id
  #     WHERE players.last_name = 'Rollus'
  #   SQL
  #   Player.includes(:game_players, ranking_histories: :ranking).where(players: {last_name: "Rollus"})

  #   ActiveRecord::Base.connection.exec_query(
  # end

end
