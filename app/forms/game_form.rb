class GameForm
  
  include ActiveModel::Model

  # Attributes
  attr_accessor :game, :club, :category, :tournament_id, :player_id, :court_type_id, :date, :status, :indoor, :round_id, :opponent,
                :victory, :set_1_number, :set_2_number, :set_3_number, :set_3_id, :tie_break_1_id, :tie_break_2_id, :tie_break_3_id, 
                :set_3_destroy, :tie_break_1_destroy, :tie_break_2_destroy, :tie_break_2_destroy, :set_1_1, :set_1_2, :tie_break_1_1,
                :tie_break_1_2, :set_2_1, :set_2_2, :tie_break_2_1, :tie_break_2_2, :set_3_1, :set_3_2, :tie_break_3_1, :tie_break_3_2, 
                :match_points_saved
                
  # Validation
  validates :club, :category, :tournament_id, :date, :player_id, :status, :court_type_id, :round_id, :opponent, :set_1_1, :set_1_2, 
            :set_2_1, :set_2_2, :match_points_saved, presence: true
  validates :set_1_1, :set_1_2, :set_2_1, :set_2_2, :set_3_1, :set_3_2, :tie_break_1_1, :tie_break_1_2,
            :tie_break_2_1, :tie_break_2_2, :tie_break_3_1, :tie_break_3_2, numericality: { only_integer: true }, allow_blank: true
  validates :set_1_1, :set_1_2, :set_2_1, :set_2_2, :set_3_1, :set_3_2, inclusion: (0..7).map(&:to_s), allow_blank: true
  validates :indoor, :victory, inclusion: { in: [ '0', '1', true, false ] }
  validate  :valid_date, :valid_opponent, :valid_score
 
  # Constructor
  def initialize(attr = {}, current_user = nil, game = nil, edit = nil)
  
    # Flatten Parameters
    attr = flatten_parameters(attr) unless attr.blank?

    # Update
    if !game.nil?
      @game = game
      user_player_id = current_user.player.id

      # Assign Attributes
      self.player_id = user_player_id
      self.club = edit ? @game.tournament.club.id : attr[:club]
      self.category = edit ? @game.tournament.category.id : attr[:category]
      self.tournament_id = edit ? @game.tournament.id : attr[:tournament_id]
      self.date = edit ? @game.date : attr[:date]
      self.court_type_id = edit ? (@game.court_type ? @game.court_type.id : nil) : attr[:court_type_id]
      self.indoor = edit ? @game.indoor : attr[:indoor]
      self.status = edit ? @game.status : attr[:status]
      self.round_id = edit ? @game.round.id : attr[:round_id]
      
      # User Check (in case somebody goes to the URL directly of a game that is not his)
      if @game.game_players.find{|player| player.player_id == user_player_id}
        self.match_points_saved = edit ? @game.game_players.find{|player| player.player_id == user_player_id}.match_points_saved : 
                                                                    attr[:match_points_saved]
        self.victory = edit ? @game.game_players.find{|player| player.player_id == user_player_id}.victory : attr[:victory]
        opponent = @game.game_players.find{|player| player.player_id != user_player_id}.player
        opponent = PlayerDecorator.new(opponent)
        self.opponent = edit ? opponent.player_description : attr[:opponent]

        # Initialize Sets and Tie Breaks
        init_sets_tie_breaks(attr, current_user, edit)
      end

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

  def update(game_form_params, current_user, game)
    return false if invalid?
    update_game(game_form_params, current_user, game)
  end

  private

  # Structure Attributes
  def sets
    [[@set_1_1, @set_1_2], [@set_2_1, @set_2_2], [@set_3_1, @set_3_2]]
  end

  def tie_breaks
    [[@tie_break_1_1, @tie_break_1_2], [@tie_break_2_1, @tie_break_2_2], [@tie_break_3_1, @tie_break_3_2]]
  end

  # Custom Validations

  def valid_date
    unless self.tournament_id.blank? || self.date.blank?
      tournament = Tournament.find(self.tournament_id)
      errors.add(:date, 'en dehors des dates du tournoi') unless self.date.to_date.between?(tournament.start_date, tournament.end_date)
    end
  end

  def valid_opponent
    unless self.opponent.blank?
      errors.add(:opponent, 'doit être sélectionné dans la liste proposée') if self.opponent.scan(/\((\d+)\)/).empty?
    end
  end

  def valid_score
    if self.status == 'completed' 
      # Sets
      sets_won = 0
      
      sets.each_with_index do |set, set_number|
        # Compute Sets Won
        unless set[0].blank? || set[1].blank?
          sets_won +=1 if set[0] > set[1]
          # Set Score Validation
          unless ([set[0], set[1]].max == '6') && ((set[0].to_i - set[1].to_i).abs >= 2) || ([set[0], set[1]].max == '7') && ((set[0].to_i - set[1].to_i).abs <= 2)
            errors.add("set_#{set_number + 1}_1".to_sym, "le score n'est pas valide") 
          end
        end 
      end

      # Victory Validation
      if self.victory == '1'
        errors.add(:victory, "le score n'est pas consistent avec le résultat du match. Selon le score, vous avez perdu le match") unless sets_won >= 2
      else
        errors.add(:victory, "le score n'est pas consistent avec le résultat du match. Selon le score, vous avez gagné le match") unless sets_won < 2
      end

      # Tie Breaks
      tie_breaks.each_with_index do |tie_break, tie_break_number|
        unless tie_break[0].blank? || tie_break[1].blank?
          # Tie Break Validation
          unless ([tie_break[0], tie_break[1]].max >= '7') && ((tie_break[0].to_i - tie_break[1].to_i).abs >= 2)
            errors.add("tie_break_#{tie_break_number + 1}_1", "le score n'est pas valide") 
          end
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
    @game_player_user.ranking = @game_player_user.player.ranking_histories.where('? >= start_date AND ? <= end_date', game_form_params[:date], game_form_params[:date])
                                                 .first.ranking
    @game_player_user.validated = true
    @game_player_opponent.victory = (game_form_params[:victory].to_i == 1) ? 0 : 1
    @game_player_opponent.match_points_saved = - game_form_params[:match_points_saved].to_i
    @game_player_opponent.player = Player.find_by_affiliation_number(game_form_params[:opponent].scan(/\((\d+)\)/)[0][0])
    @game_player_opponent.ranking =  @game_player_opponent.player.ranking_histories.where('? >= start_date AND ? <= end_date', game_form_params[:date], game_form_params[:date])
                                                          .first.ranking
    @game_player_opponent.validated = false
  end

  # Update

  def update_game(game_form_params, current_user, game)
    # Player Table and associated nested tables
    game.update(game_form_params.except(:club, :category, :opponent, :victory, :match_points_saved))

    # GamePlayers Table
    user_player_id = current_user.player.id
    @game_player_user = game.game_players.find{|player| player.player_id == user_player_id}
    @game_player_user.update(victory: game_form_params[:victory], match_points_saved: game_form_params[:match_points_saved], validated: true)
    @game_player_opponent = game.game_players.find{|player| player.player_id != user_player_id}
    opponent = Player.find_by_affiliation_number(game_form_params[:opponent].scan(/\((\d+)\)/)[0][0])
    @game_player_opponent.update(player_id: opponent.id, 
                                 ranking_id: opponent.ranking_histories.where('? >= start_date AND ? <= end_date', game_form_params[:date], game_form_params[:date]).first.ranking.id,
                                 victory:  (game_form_params[:victory].to_i == 1) ? 0 : 1,
                                 match_points_saved:  - game_form_params[:match_points_saved].to_i, validated: false)
  end

   # Initializing Methods

  def init_sets_tie_breaks(attr, current_user, edit)
    user_score_order = GamePlayerOrderService.maintain?(@game, current_user.player.id)
    (1..3).each_with_index do |set_index|
      # Sets
      set = @game.game_sets.find{|set| set.set_number == set_index}
      if set
        games_1 = (user_score_order ? set.games_1 : set.games_2)
        games_2 = (user_score_order ? set.games_2 : set.games_1)
      end

      self.send("set_#{set_index}_1=", (edit ? games_1 : attr["set_#{set_index}_1".to_sym]))
      self.send("set_#{set_index}_2=", (edit ? games_2 : attr["set_#{set_index}_2".to_sym]))

      # Tie Breaks
      if set
        if set.tie_break
          points_1 = (user_score_order ? set.tie_break.points_1 : set.tie_break.points_2)
          points_2 = (user_score_order ? set.tie_break.points_2 : set.tie_break.points_1)
        end
      end 

      self.send("tie_break_#{set_index}_1=", (edit ? points_1 : attr["tie_break_#{set_index}_1".to_sym]))
      self.send("tie_break_#{set_index}_2=", (edit ? points_2 : attr["tie_break_#{set_index}_2".to_sym]))
      
    end
  end
  
  # Flatten Parameters

  def flatten_parameters(params)
    flat_params = params.except(:game_sets_attributes)
    set_index = 0
    params[:game_sets_attributes].each do |set_nbr|
      set_index += 1
      set_games = 0
      set_nbr[1].each do |set_key, set_value|
        set_games += 1 if set_key != 'set_number' && set_key!= 'id'
        tb_index = 0
        if set_value.is_a?((ActionController::Parameters))
          set_value.each do |tb_key, tb_value|
            tb_index += 1 if tb_key != 'id'
            flat_params["tie_break_#{set_index}_#{tb_index}".to_sym] = tb_value if tb_key != 'id'
          end
        else
          flat_params["set_#{set_index}_#{set_games}".to_sym] = set_value if set_key != 'set_number' && set_key!= 'id'
        end
      end
    end
    flat_params
  end

end