module NestedUserConcern
  extend ActiveSupport::Concern

  included do
    before_create :find_or_create_nested_children
  end

  private

  def find_or_create_nested_children
    player = Player.find_by_affiliation_number(self.player.affiliation_number)
    if player 
      temp_player_data = self.player
      temp_ranking_history = self.player.ranking_histories.max_by{|ranking| ranking.start_date}

      self.player= player
      self.player.assign_attributes(first_name: temp_player_data.first_name, 
                                    last_name: temp_player_data.last_name,
                                    club_id: temp_player_data.club_id,
                                    gender: temp_player_data.gender,
                                    birthdate: temp_player_data.birthdate,
                                    dominant_hand: temp_player_data.dominant_hand)
      
      if player.ranking_histories.find_by_player_id_and_year_and_year_number_and_start_date_and_end_date(player.id, temp_ranking_history.year,
                                                                                                         temp_ranking_history.year_number, temp_ranking_history.start_date, 
                                                                                                         temp_ranking_history.end_date)
        self.player.ranking_histories = player.ranking_histories
        self.player.ranking_histories.max_by{|ranking| ranking.start_date}.assign_attributes(ranking_id: temp_ranking_history.ranking_id, year: temp_ranking_history.year, 
                                                             year_number: temp_ranking_history.year_number, start_date: temp_ranking_history.start_date,
                                                             end_date: temp_ranking_history.end_date)
      else
        self.player.ranking_histories << temp_ranking_history
      end
    end
  end
end