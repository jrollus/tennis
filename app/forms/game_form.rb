class GameForm
    include ActiveModel::Model
    attr_accessor :club, :category, :tournament_id, :date, :status, :court_type, :indoor, :round, :opponent, :player_id, :court_type_id, :victory, :set_1_number, :set_2_number, :set_3_number,
                  :set_3_id, :tie_break_1_id, :tie_break_2_id, :tie_break_3_id, :set_3_destroy, :tie_break_1_destroy, :tie_break_2_destroy, :tie_break_2_destroy,
                  :set_1_1, :set_1_2, :tie_break_1_1, :tie_break_1_2, :set_2_1, :set_2_2, :tie_break_2_1, :tie_break_2_2, 
                  :set_3_1, :set_3_2, :tie_break_3_1, :tie_break_3_2, :match_points_saved
                  
    validates :club, :category, :tournament_id, :date, :status, :court_type, :indoor, :round, :opponent, :set_1_number, :set_2_number, :set_3_number,
    :set_1_1, :set_1_2, :tie_break_1_1, :tie_break_1_2, :set_2_1, :set_2_2, :tie_break_2_1, :tie_break_2_2, 
    :set_3_1, :set_3_2, :tie_break_3_1, :tie_break_3_2, presence: true

    def save
      return false if invalid?
    end

end