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

  # Reflexive Relation
  belongs_to :player_creator, class_name: 'Player', optional: true, foreign_key: 'player_creator_id'
  has_many :players_created, class_name: 'Player', foreign_key: 'player_creator_id'

  # Nested attributes
  accepts_nested_attributes_for :ranking_histories

  # Validations
  validates :club, :affiliation_number, :gender, :first_name, :last_name, :birthdate, :dominant_hand, presence: true
  validate :affiliation_number_check
  
  # PG Search
  include PgSearch::Model
  pg_search_scope :search_by_name_and_affiliation_number,
    against: [:first_name, :last_name, :affiliation_number],
    using: {
      tsearch: { prefix: true }
  }
  
  # Points

  def compute_points
    games = PlayerPointsQuery.new(Game.all, self).get_games(@max_date)
    nbr_participant_rules = NbrParticipantRule.all
    points_by_tournament = []
    games.each do |tournament_key, tournament_value| 
      points = 0
      unless (games.size == 1) && !tournament_value.first.game_players.find{|player| player.player_id == selected_player_id}.victory
        points += games.size * 2
        last_round_game = tournament_value.min{|a, b| a.round_id <=> b.round_id}
        round_id = last_round_game.round_id
        round_id = 1 if (round_id == 2)  && last_round_game.game_players.find{|player| player.player_id == self.id}.victory
        nbr_participants = tournament_value.first.tournament.nbr_participants
        weight = nbr_participant_rules.find{|e| nbr_participants.between?(e.lower_bound, e.upper_bound)}.weight
        points += tournament_value.first.tournament.category.category_rounds.find{|category_round| category_round.round_id = round_id}.points * weight  
        tournament_value.each do |game|
          victory = game.game_players.find{|player| player.player_id == self.id}.victory
          opponent =  game.game_players.find{|player| player.player_id != self.id}
          if opponent
            points += opponent.ranking.points if victory
          end
        end
      end
      points_by_tournament << points
    end

    player_points = points_by_tournament.sum(0.0) / points_by_tournament.size
    player_points *= (1 - ((6 - points_by_tournament.size) * 0.04)) if points_by_tournament.size < 6
    byebug
  end

  private 

  # Custom Validations
  def affiliation_number_check
    player = Player.find_by_affiliation_number(self.affiliation_number)
    # Created through nested attributes
    if self.user
      if player
          errors.add(:affiliation_number, 'Déjà associé à un autre e-mail') if (!player.user_id.nil? && (player.user.email != self.user.email))
      end
    # Create as a stand-alone player
    else
      errors.add(:affiliation_number, 'Déjà existant') if (player && self.new_record?)
    end
  end
  
end
