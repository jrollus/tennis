class GamesController < ApplicationController
  before_action :set_players_and_clubs_and_courts_and_rounds, only: [:new, :create, :edit, :update]
  before_action :set_game, only: [:edit, :update]

  def index
    @max_date = Game.maximum(:date).year
    @min_date = Game.minimum(:date).year

    @games = PlayerGamesQuery.new(policy_scope(Game), current_user.player).get_games(@max_date)
    @games = GameIndexDecorator.new(@games)
  end

  def new
    @form = GameForm.new
    authorize @form
  end

  def create
    @form = GameForm.new(game_form_params)

    authorize @form
    if @form.save(game_form_params, current_user)
      redirect_to games_path 
    else
      refresh_cascading_dropdowns
      @form.date = @form.date.to_date
      render :new
    end
  end

  def edit
    @form = GameForm.new({}, current_user, @game, true)
    refresh_cascading_dropdowns
    authorize @form
  end

  def update
    @form = GameForm.new(game_form_params, current_user, @game, false)
    authorize @form
    if @form.update(game_form_params, current_user, @game)
      redirect_to games_path
    else
      refresh_cascading_dropdowns
      @form.date = @form.date.to_date
      render :edit
    end 
  end

  def destroy
    @game = Game.find(params[:id])
    authorize @game
    @game.destroy
    redirect_to games_path
  end

  def validate
    @game = Game.includes(:game_players).find(params[:game_id])
    authorize @game
    @game.game_players.find{|player| player.player_id == current_user.player.id}.update(validated: true)
  end

  private

  def game_form_params
    params.require(:game_form).permit(:club, :category, :tournament_id, :player_id, :court_type_id, :date, :status, :round_id, :court_type, :indoor, :opponent, :victory, :match_points_saved,
                                      game_sets_attributes: [:id, :set_number, :games_1, :games_2, :_destroy, tie_break_attributes: [:id, :points_1, :points_2, :_destroy]])
  end
  
  def set_players_and_clubs_and_courts_and_rounds
    @player = PlayerDecorator.new(current_user.player)
    @clubs = ClubsMatchingQuery.new(@player).get_clubs_matching
    @courts = CourtType.all.map{|court_type| [court_type.court_type.titleize, court_type.id]}
    @rounds = Round.where.not(name: 'vainqueur').map{|round| [round.name.gsub('_', '/').capitalize, round.id]}
  end

  def set_game
    @game = Game.includes(game_players: {player: {ranking_histories: :ranking}}, game_sets: :tie_break, tournament: [:club, :category]).find(params[:id])
  end

  def refresh_cascading_dropdowns
    query = CascadingDropdownsQuery.new(policy_scope(Tournament), @form.club, current_user.player, false)
    @categories = query.select_categories unless @form.club.blank?
    @tournament_dates = query.select_dates(@form.category) unless @form.category.blank?
  end
end
