class GamesController < ApplicationController
  before_action :set_clubs_courts, only: [:new, :edit]
  before_action :set_game, only:[:edit]

  def index
  end

  def show
  end

  def new
    @form = GameForm.new
    authorize @form
  end

  def create
    # Player Table and associated nested tables
    @game = Game.new(game_form_params.except(:club, :category, :opponent, :victory, :match_points_saved))
    authorize @game
    # GamerPlayers Table
    @game_player_user = GamePlayer.new
    @game_player_opponent = GamePlayer.new
    create_game_player

    if @game.save
      @game_player_user.game = @game
      @game_player_user.save
      @game_player_opponent.game = @game
      @game_player_opponent.save
      redirect_to root_path 
    else
      render :new
    end
  end

  def edit
    @form = GameForm.new
    @form.date = @game.date 
    @form.court_type = @game.court_type
    @form.indoor = @game.indoor
    @form.status = @game.status
    @form.round = @game.round
    @form.victory = @game.game_players.where(player_id: current_user.player.id).first.victory
    opponent = @game.game_players.where.not(player_id: current_user.player.id).first.player

    @game.game_sets.each do |set|
      case set.set_number
      when 1
        @form.set_1_1 = set.games_1
        @form.set_1_2 = set.games_2
        @form.tie_break_1_1 = set.tie_break.points_1 unless set.tie_break.nil?
        @form.tie_break_1_2 = set.tie_break.points_2 unless set.tie_break.nil?
      when 2
        @form.set_2_1 = set.games_1
        @form.set_2_2 = set.games_2
        @form.tie_break_2_1 = set.tie_break.points_1 unless set.tie_break.nil?
        @form.tie_break_2_2 = set.tie_break.points_2 unless set.tie_break.nil?
      when 3
        @form.set_3_1 = set.games_1
        @form.set_3_2 = set.games_2
        @form.tie_break_3_1 = set.tie_break.points_1 unless set.tie_break.nil?
        @form.tie_break_3_2 = set.tie_break.points_2 unless set.tie_break.nil?
      end
    end

    @form.opponent = "#{opponent.first_name.capitalize} #{opponent.last_name.capitalize} (#{opponent.affiliation_number}) #{opponent.ranking_histories.last.ranking.name}"
    authorize @form
  end

  def update
  end

  def destroy
  end

  private

  def game_form_params
    params.require(:game_form).permit(:club, :category, :tournament_id, :date, :status, :round, :court_type, :indoor, :opponent, :victory, :match_points_saved,
                                      game_sets_attributes: [:set_number, :games_1, :games_2, tie_break_attributes: [:points_1, :points_2]])
  end

  def set_game
    @game = Game.includes(game_players: {player: {ranking_histories: :ranking}}, game_sets: :tie_break).find(params[:id])
  end

  def set_clubs_courts
    player_age = Date.today.year - current_user.player.birthdate.year
    query = "categories.gender = ? AND categories.c_type = 'single' AND ? >= categories.age_min AND ? < categories.age_max "
    @clubs = Club.joins(tournaments: :category).where(query, current_user.player.gender, player_age, player_age).uniq.sort
    @courts = Court.distinct.pluck(:court_type).sort.map{|court| court.titleize}
  end

  def create_game_player
    @game_player_user.victory = game_form_params[:victory]
    @game_player_user.match_points_saved = game_form_params[:match_points_saved].to_i
    @game_player_user.player = current_user.player
    @game_player_opponent.victory = (game_form_params[:victory].to_i == 1) ? 0 : 1
    @game_player_opponent.match_points_saved = - game_form_params[:match_points_saved].to_i
    @game_player_opponent.player = Player.find_by_affiliation_number(game_form_params[:opponent].scan(/\((\d+)\)/)[0][0])
  end
end
