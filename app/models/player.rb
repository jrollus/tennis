class Player < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :club
  has_many :game_players
  has_many :games, through: :game_players
  has_many :tournaments, through: :games
  has_many :categories, through: :tournaments
  
  # Nested attributes
  has_many :ranking_histories
  has_many :ranking, through: :ranking_histories
  accepts_nested_attributes_for :ranking_histories

  # PG Search
  include PgSearch::Model
  pg_search_scope :search_by_name_and_affiliation_number,
    against: [:first_name, :last_name, :affiliation_number],
    using: {
      tsearch: { prefix: true }
  }
  
  def get_age
    Date.today.year - self.birthdate.year
  end

  def get_win_ratio
    nbr_games = self.game_players.count
    nbr_victories = self.game_players.where(victory: true).count
    nbr_victories / nbr_games
  end

  def get_nbr_win_two_sets
    GamePlayer.joins(:player, :game).where(players: {id: self.id}, game_players: {victory: true}, games: {set_3: nil}).count
  end

  def get_nbr_loss_two_sets
    GamePlayer.joins(:player, :game).where(players: {id: self.id}, game_players: {victory: false}, games: {set_3: nil}).count
  end

  def get_nbr_win_three_sets
    GamePlayer.joins(:player, :game).where(players: {id: self.id}, game_players: {victory: true}).where.not(games: {set_3: nil}).count
  end

  def get_nbr_loss_three_sets
    GamePlayer.joins(:player, :game).where(players: {id: self.id}, game_players: {victory: false}).where.not(games: {set_3: nil}).count
  end

  # def get_nbr_tie_breaks
  #   # tie_breaks_data = []
  #   # (1..3).each do |index|
  #   #   tie_breaks_data << {
  #   #     won:  Game.joins(game_players: :player).where("players.id = ? AND score_direction = ? AND (set_#{index} = ? OR set_#{index} = ?)", olivier.id, olivier.affilitiation_number, "7/6", "4/3").count
  #   #     lost:  Game.joins(game_players: :player).where("players.id = ? AND score_direction = ? AND (set_#{index} = ? OR set_#{index} = ?)", olivier.id, olivier.affilitiation_number, "6/7", "3/4").count
  #   #   }
  #   # end
  # end

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
