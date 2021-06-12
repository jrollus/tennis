class Player < ApplicationRecord
  # Relations
  belongs_to :user, optional: true
  belongs_to :club
  has_many :game_players
  has_many :games, through: :game_players
  has_many :tournaments, through: :games
  has_many :categories, through: :tournaments
  has_many :ranking_histories, dependent: :destroy
  has_many :ranking, through: :ranking_histories

  # Reflexive Relation
  belongs_to :player_creator, class_name: 'Player', optional: true, foreign_key: 'player_creator_id'
  has_many :players_created, class_name: 'Player', foreign_key: 'player_creator_id'

  # Nested attributes
  accepts_nested_attributes_for :ranking_histories

  # Validations
  validates :affiliation_number, :gender, :first_name, :last_name, :birthdate, :dominant_hand, presence: true
  validates :affiliation_number, format: { with: /\A\d{7}\z/, message: "le numéro d'affiliation doit être composé de 7 chiffres"}
  validate :affiliation_number_check, on: :create
  
  # PG Search
  include PgSearch::Model
  pg_search_scope :search_by_name_and_affiliation_number,
    against: [:first_name, :last_name, :affiliation_number],
    using: {
      tsearch: { prefix: true }
  }
  
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
