class GameForm
  
  include ActiveModel::Model

  # Relations
  attr_accessor :club, :category, :tournament_id, :player_id, :court_type_id, :date, :status, :court_type, :indoor, :round, :opponent,
                :victory, :set_1_number, :set_2_number, :set_3_number, :set_3_id, :tie_break_1_id, :tie_break_2_id, :tie_break_3_id, 
                :set_3_destroy, :tie_break_1_destroy, :tie_break_2_destroy, :tie_break_2_destroy, :set_1_1, :set_1_2, :tie_break_1_1,
                :tie_break_1_2, :set_2_1, :set_2_2, :tie_break_2_1, :tie_break_2_2, :set_3_1, :set_3_2, :tie_break_3_1, :tie_break_3_2, 
                :match_points_saved
  
  # Validation
  #validates :club, :category, :tournament_id, , :player_id, :court_type_id, :date, :status, :court_type, :indoor, :round, :opponent, presence: true

  # Constructor
  def initialize(attr = {})
    if !attr["id"].nil?
      @game = Game.includes(game_players: {player: {ranking_histories: :ranking}}, game_sets: :tie_break, tournament: [:club, :category]).find(params[:id])
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

  def update
    return false if invalid?
    update_game
  end

  private

  def save_game(game_form_params, current_user)
    # Player Table and associated nested tables
    @game = Game.new(game_form_params.except(:club, :category, :opponent, :victory, :match_points_saved))
  
    # GamerPlayers Table
    @game_player_user = GamePlayer.new
    @game_player_opponent = GamePlayer.new
    create_game_player(game_form_params, current_user)
    @game_player_user.game = @game
    @game_player_user.save
    @game_player_opponent.game = @game
    @game_player_opponent.save
  end

  def update_game

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

end