class GamesController < ApplicationController
  before_action :set_clubs_and_courts, only: [:new, :edit]
  before_action :set_game, only: [:edit, :update]

  def index
  end

  def show
  end

  def new
    @form = GameForm.new
    authorize @form
  end

  def create
    @form = GameForm.new(flatten_parameters(game_form_params))

    authorize @form
    if @form.save(game_form_params, current_user)
      redirect_to root_path 
    else
      render :new
    end
  end

  def edit
    @form = GameForm.new(@game.attributes.symbolize_keys.slice(:date, :court_type, :indoor, :status, :round), current_user, @game)
    
    # Initialize Cascading Dropdowns
    @selected_club = @game.tournament.club.id
    @categories = select_categories
    @category_selected = @game.tournament.category.id
    @tournament_dates = select_dates
    @dates_selected = "#{@game.tournament.start_date.strftime("%d/%m/%Y")} - #{@game.tournament.end_date.strftime("%d/%m/%Y")}"
    @court_selected = @game.court_type.id

    authorize @form
  end

  def update
    @form = GameForm.new(flatten_parameters(game_form_params))
    authorize @form
    if @form.update(game_form_params, current_user, @game)
      redirect_to root_path
    else
      render :edit
    end 
  end

  def destroy
  end

  private

  def game_form_params
    params.require(:game_form).permit(:club, :category, :tournament_id, :player_id, :court_type_id, :date, :status, :round, :court_type, :indoor, :opponent, :victory, :match_points_saved,
                                      game_sets_attributes: [:id, :set_number, :games_1, :games_2, :_destroy, tie_break_attributes: [:id, :points_1, :points_2, :_destroy]])
  end

  def flatten_parameters(params)
    flat_params = params.except(:game_sets_attributes)
    set_index = 0
    params[:game_sets_attributes].each do |set_nbr|
      set_index += 1
      set_games = 0
      set_nbr[1].each do |set_key, set_value|
        set_games += 1 if set_key != "set_number" && set_key!= "id"
        tb_index = 0
        if set_value.is_a?((ActionController::Parameters))
          set_value.each do |tb_key, tb_value|
            tb_index += 1 if tb_key != "id"
            flat_params["tie_break_#{set_index}_#{tb_index}".to_sym] = tb_value if tb_key != "id"
          end
        else
          flat_params["set_#{set_index}_#{set_games}".to_sym] = set_value if set_key != "set_number" && set_key!= "id"
        end
      end
    end
    flat_params
  end

  def set_clubs_and_courts
    query = "categories.gender = ? AND categories.c_type = 'single' AND ? >= categories.age_min AND ? < categories.age_max "
    @clubs = Club.joins(tournaments: :category).where(query, current_user.player.gender, current_user.player.get_age, current_user.player.get_age).uniq.sort
    @courts = CourtType.all.map{|court_type| [court_type.court_type.titleize, court_type.id]}
  end

  def set_game
    @game = Game.includes(game_players: {player: {ranking_histories: :ranking}}, game_sets: :tie_break, tournament: [:club, :category]).find(params[:id])
  end

  def select_categories
    query = "tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max "
    tournaments = Tournament.includes(:category).joins(:category)
                  .where(query,  @game.tournament.club.id, current_user.player.gender, 'single', current_user.player.get_age, current_user.player.get_age)
    tournaments.map{|tournament| [tournament.category.category, tournament.category.id]}.uniq.sort {|a,b| a[1] <=> b[1]}
  end

  def select_dates
    query = "tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max AND tournaments.category_id = ?"
    tournaments = Tournament.includes(:category).joins(:category)
                  .where(query, @game.tournament.club.id, current_user.player.gender,'single', current_user.player.get_age, current_user.player.get_age, @game.tournament.category.id)
    tournaments.map{|tournament| ["#{tournament.start_date.strftime("%d/%m/%Y")} - #{tournament.end_date.strftime("%d/%m/%Y")}", tournament.id]}.uniq.sort {|a,b| a[1] <=> b[1]}
  end

end
