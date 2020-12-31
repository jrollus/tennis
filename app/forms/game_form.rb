class GameForm
  
  include ActiveModel::Model

  # Attributes
  attr_accessor :club, :category, :tournament_id, :player_id, :court_type_id, :date, :status, :indoor, :round, :opponent,
                :victory, :set_1_number, :set_2_number, :set_3_number, :set_3_id, :tie_break_1_id, :tie_break_2_id, :tie_break_3_id, 
                :set_3_destroy, :tie_break_1_destroy, :tie_break_2_destroy, :tie_break_2_destroy, :set_1_1, :set_1_2, :tie_break_1_1,
                :tie_break_1_2, :set_2_1, :set_2_2, :tie_break_2_1, :tie_break_2_2, :set_3_1, :set_3_2, :tie_break_3_1, :tie_break_3_2, 
                :match_points_saved
  
  # Validation
  validates :club, :category, :tournament_id, :date, :player_id, :status, :court_type_id, :round, :opponent, :set_1_1, :set_1_2, 
            :set_2_1, :set_2_2, :match_points_saved, presence: true
  validates :set_1_1, :set_1_2, :set_2_1, :set_2_2, :set_3_1, :set_3_2, :tie_break_1_1, :tie_break_1_2,
            :tie_break_2_1, :tie_break_2_2, :tie_break_3_1, :tie_break_3_2, numericality: { only_integer: true }, allow_blank: true
  validates :set_1_1, :set_1_2, :set_2_1, :set_2_2, :set_3_1, :set_3_2, inclusion: (1..7).map(&:to_s), allow_blank: true
  validates :indoor, :victory, inclusion: { in: [ "0", "1", true, false ] }
  validate :valid_date, :valid_opponent, :valid_score
 
  # Constructor
  def initialize(attr = {}, current_user = nil, game = nil)
    # Update
    if !current_user.nil?
      @game = game
      # Assign Attributes
      self.assign_attributes(attr)

      # Initiliaze General Form Parameters
      self.victory = @game.game_players.where(player_id: current_user.player.id).first.victory
      opponent = @game.game_players.where.not(player_id: current_user.player.id).first.player
      self.opponent = "#{opponent.first_name.capitalize} #{opponent.last_name.capitalize} (#{opponent.affiliation_number}) #{opponent.ranking_histories.last.ranking.name}"

      # Initialize Sets and Tie Breaks
      init_sets_tie_breaks(current_user, @game)

    # Create
    else
      super(attr)
    end
  end

  def persisted?
     @game.nil? ? false : @game.persisted?
  end

  def id
    @game.nil? ? nil : @game.id
  end

  def save(game_form_params, current_user)
    return false if invalid?
    save_game(game_form_params, current_user)
  end

  def update(game_form_params, current_user)
    return false if invalid?
    update_game(game_form_params, current_user)
  end

  private

  # Custom Validation

  def valid_date
    if self.tournament_id && !self.date.empty?
      tournament = Tournament.find(self.tournament_id)
      errors.add(:date, "en dehors des dates du tournoi") unless self.date.to_date.between?(tournament.start_date, tournament.end_date)
    end
  end

  def valid_opponent
    unless self.opponent.empty?
      errors.add(:opponent, "doit être sélectionné dans la liste proposée") if self.opponent.scan(/\((\d+)\)/).empty?
    end
  end

  def valid_score
    if self.status == 'completed' 
      # Victory
      sets_won = 0
      
      unless self.set_1_1.nil? || self.set_1_2.nil?
        sets_won +=1 if self.set_1_1 > self.set_1_2
      end

      unless self.set_2_1.nil? || self.set_2_2.nil?
        sets_won +=1 if self.set_2_1 > self.set_2_2
      end

      unless self.set_3_1.nil? || self.set_3_2.nil?
        sets_won +=1 if self.set_3_1 > self.set_3_2
      end 

      if self.victory == '1'
        errors.add(:victory, "le score n'est pas consistent avec le résultat du match. Selon le score, vous avez perdu le match") unless sets_won >= 2
      else
        errors.add(:victory, "le score n'est pas consistent avec le résultat du match. Selon le score, vous avez gagné le match") unless sets_won < 2
      end

      # Set 1
      unless ([self.set_1_1, self.set_1_2].max == "6") && ((self.set_1_1.to_i - self.set_1_2.to_i).abs >= 2) || ([self.set_1_1, self.set_1_2].max == "7") && ((self.set_1_1.to_i - self.set_1_2.to_i).abs <= 2)
        errors.add(:set_1_1, "le score n'est pas valide") 
      end

      # # Set 2
      unless ([self.set_2_1, self.set_2_2].max == "6") && ((self.set_2_1.to_i - self.set_2_2.to_i).abs >= 2) || ([self.set_2_1, self.set_2_2].max == "7") && ((self.set_2_1.to_i - self.set_2_2.to_i).abs <= 2)
        errors.add(:set_1_1, "le score n'est pas valide") 
      end

      # Set 3
      if self.set_3_1 && self.self_set_3_2
        unless ([self.set_3_1, self.set_3_2].max == "6") && ((self.set_3_1.to_i - self.set_3_2.to_i).abs >= 2) || ([self.set_3_1, self.set_3_2].max == "7") && ((self.set_3_1.to_i - self.set_3_2.to_i).abs <= 2)
          errors.add(:set_1_1, "le score n'est pas valide") 
        end
      end

      # Tie Break 1
      if !self.tie_break_1_1.nil? && !self.tie_break_1_2.nil?
        unless ([self.tie_break_1_1, self.tie_break_1_2].max >= "7") && ((self.tie_break_1_1.to_i - self.tie_break_1_2.to_i).abs >= 2)
          errors.add(:tie_break_1_1, "le score n'est pas valide") 
        end
      end

      # Tie Break 2
      if !self.tie_break_2_1.nil? && !self.tie_break_2_2.nil?
        unless ([self.tie_break_2_1, self.tie_break_2_2].max >= "7") && ((self.tie_break_2_1.to_i - self.tie_break_2_2.to_i).abs >= 2)
          errors.add(:tie_break_2_1, "le score n'est pas valide") 
        end
      end

      # Tie Break 3
       if !self.tie_break_3_1.nil? && !self.tie_break_3_2.nil?
        unless ([self.tie_break_3_1, self.tie_break_3_2].max >= "7") && ((self.tie_break_3_1.to_i - self.tie_break_3_2.to_i).abs >= 2)
          errors.add(:tie_break_3_1, "le score n'est pas valide") 
        end
      end
    end   
  end

  # Save
  def save_game(game_form_params, current_user)
    # Player Table and associated nested tables
    @game = Game.new(game_form_params.except(:club, :category, :opponent, :victory, :match_points_saved))
    @game.save 

    # GamerPlayers Table
    @game_player_user = GamePlayer.new
    @game_player_opponent = GamePlayer.new
    create_game_player(game_form_params, current_user)
    @game_player_user.game = @game
    @game_player_user.save
    @game_player_opponent.game = @game
    @game_player_opponent.save

  end

  def create_game_player(game_form_params, current_user)
    @game_player_user.victory = game_form_params[:victory]
    @game_player_user.match_points_saved = game_form_params[:match_points_saved].to_i
    @game_player_user.player = current_user.player
    @game_player_user.validated = true
    @game_player_opponent.victory = (game_form_params[:victory].to_i == 1) ? 0 : 1
    @game_player_opponent.match_points_saved = - game_form_params[:match_points_saved].to_i
    @game_player_opponent.player = Player.find_by_affiliation_number(game_form_params[:opponent].scan(/\((\d+)\)/)[0][0])
    @game_player_opponent.validated = false
  end

  # Update

  def update_game(game_form_params, current_user)
    # Player Table and associated nested tables
    @game.update(game_form_params.except(:club, :category, :opponent, :victory, :match_points_saved))

    # GamePlayers Table
    @game_player_user = game.game_players.where(player_id: current_user.player.id).first
    @game_player_user.update(victory: game_form_params[:victory], match_points_saved: game_form_params[:match_points_saved], validated: true)
    @game_player_opponent = game.game_players.where.not(player_id: current_user.player.id).first
    @game_player_opponent.update(player_id: Player.find_by_affiliation_number(game_form_params[:opponent].scan(/\((\d+)\)/)[0][0]).id, 
                                 victory:  (game_form_params[:victory].to_i == 1) ? 0 : 1,
                                 match_points_saved:  - game_form_params[:match_points_saved].to_i, validated: false)
  end

   # Initializing Methods

  def init_sets_tie_breaks(current_user, game)
    user_score_order = game.check_user_order(current_user.player.id)
    game.game_sets.each do |set|
      case set.set_number
      when 1
        if user_score_order
          self.set_1_1 = set.games_1
          self.set_1_2 = set.games_2
          self.tie_break_1_1 = set.tie_break.points_1 unless set.tie_break.nil?
          self.tie_break_1_2 = set.tie_break.points_2 unless set.tie_break.nil?
        else
          self.set_1_1 = set.games_2
          self.set_1_2 = set.games_1
          self.tie_break_1_1 = set.tie_break.points_2 unless set.tie_break.nil?
          self.tie_break_1_2 = set.tie_break.points_1 unless set.tie_break.nil?
        end
      when 2
        if user_score_order
          self.set_2_1 = set.games_1
          self.set_2_2 = set.games_2
          self.tie_break_2_1 = set.tie_break.points_1 unless set.tie_break.nil?
          self.tie_break_2_2 = set.tie_break.points_2 unless set.tie_break.nil?
        else
          self.set_2_1 = set.games_2
          self.set_2_2 = set.games_1
          self.tie_break_2_1 = set.tie_break.points_2 unless set.tie_break.nil?
          self.tie_break_2_2 = set.tie_break.points_1 unless set.tie_break.nil?
        end
      when 3
        if user_score_order
          self.set_3_1 = set.games_1
          self.set_3_2 = set.games_2
          self.tie_break_3_1 = set.tie_break.points_1 unless set.tie_break.nil?
          self.tie_break_3_2 = set.tie_break.points_2 unless set.tie_break.nil?
        else
          self.set_3_1 = set.games_2
          self.set_3_2 = set.games_1
          self.tie_break_3_1 = set.tie_break.points_2 unless set.tie_break.nil?
          self.tie_break_3_2 = set.tie_break.points_1 unless set.tie_break.nil?
        end
      end
    end
  end
  
end