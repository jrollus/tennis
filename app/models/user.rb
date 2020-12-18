class User < ApplicationRecord
  # Devise
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Active Storage
  has_one_attached :avatar

  # Relations
  has_one :player
  accepts_nested_attributes_for :player
  has_many :ranking_histories, through: :player
  has_many :clubs
  
  # Callbacks
  before_create :find_or_create_nested_children

  private

  def find_or_create_nested_children
    player = Player.find_by_affiliation_number(self.player.affiliation_number)
    if player
      temp_player_data = self.player
      temp_ranking_history = self.player.ranking_histories.last

      self.player= player
      self.player.assign_attributes(first_name: temp_player_data.first_name, 
                                    last_name: temp_player_data.last_name,
                                    club_id: temp_player_data.club_id,
                                    gender: temp_player_data.gender,
                                    birthdate: temp_player_data.birthdate,
                                    dominant_hand: temp_player_data.dominant_hand)
      
      if player.ranking_histories.find_by_player_id_and_year(player.id, temp_ranking_history.year)
        self.player.ranking_histories = player.ranking_histories
        self.player.ranking_histories.last.assign_attributes(ranking_id: temp_ranking_history.ranking_id, year: temp_ranking_history.year)
      else
        self.player.ranking_histories << temp_ranking_history
      end
      
    end
  end

end
