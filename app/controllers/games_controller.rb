class GamesController < ApplicationController
  before_action :set_clubs_courts, only: [:new, :edit]
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
    @form = GameForm.new(@game.attributes.symbolize_keys.slice(:date, :court_type, :indoor, :status, :round))
    authorize @form

    # Initialize Cascading Dropdowns
    @selected_club = @game.tournament.club.id
    @categories = select_categories()
    @category_selected = @game.tournament.category.category
    @tournament_dates = select_dates()
    @dates_selected = "#{@game.tournament.start_date.strftime("%d/%m/%Y")} - #{@game.tournament.end_date.strftime("%d/%m/%Y")}"

    # Initiliaze General Form Parameters
    @form.victory = @game.game_players.where(player_id: current_user.player.id).first.victory
    opponent = @game.game_players.where.not(player_id: current_user.player.id).first.player
    @form.opponent = "#{opponent.first_name.capitalize} #{opponent.last_name.capitalize} (#{opponent.affiliation_number}) #{opponent.ranking_histories.last.ranking.name}"

    # Initialize Sets and Tie Breaks
    init_sets_tie_breaks
  end

  def update
    byebug
    @game.update(game_form_params.except(:club, :category, :opponent, :victory, :match_points_saved))
    authorize @game
  end

  def destroy
  end

  private

  def game_form_params
    params.require(:game_form).permit(:club, :category, :tournament_id, :date, :status, :round, :court_type, :indoor, :opponent, :victory, :match_points_saved,
                                      game_sets_attributes: [:id, :set_number, :games_1, :games_2, :_destroy, tie_break_attributes: [:id, :points_1, :points_2, :_destroy]])
  end

  def set_game
    @game = Game.includes(game_players: {player: {ranking_histories: :ranking}}, game_sets: :tie_break, tournament: :club, tournament: :category).find(params[:id])
  end

  def set_clubs_courts
    query = "categories.gender = ? AND categories.c_type = 'single' AND ? >= categories.age_min AND ? < categories.age_max "
    @clubs = Club.joins(tournaments: :category).where(query, current_user.player.gender, current_user.player.get_age, current_user.player.get_age).uniq.sort
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

  def select_categories
    query = "tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max "
    tournaments = policy_scope(Tournament).includes(:category).joins(:category)
                  .where(query,  @game.tournament.club.id, current_user.player.gender, 'single', current_user.player.get_age, current_user.player.get_age)
    tournaments.map{|tournament| [tournament.category.category, tournament.category.id]}.uniq.sort {|a,b| a[1] <=> b[1]}
  end

  def select_dates
    query = "tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max AND tournaments.category_id = ?"
    tournaments = policy_scope(Tournament).includes(:category).joins(:category)
                  .where(query, @game.tournament.club.id, current_user.player.gender,'single', current_user.player.get_age, current_user.player.get_age, @game.tournament.category.id)
    tournaments.map{|tournament| ["#{tournament.start_date.strftime("%d/%m/%Y")} - #{tournament.end_date.strftime("%d/%m/%Y")}", tournament.id]}.uniq.sort {|a,b| a[1] <=> b[1]}
  end

 def init_sets_tie_breaks
  user_score_order = @game.check_user_order(current_user.player.id)
  @game.game_sets.each do |set|
    case set.set_number
    when 1
      if user_score_order
        @form.set_1_1 = set.games_1
        @form.set_1_2 = set.games_2
        @form.tie_break_1_1 = set.tie_break.points_1 unless set.tie_break.nil?
        @form.tie_break_1_2 = set.tie_break.points_2 unless set.tie_break.nil?
      else
        @form.set_1_1 = set.games_2
        @form.set_1_2 = set.games_1
        @form.tie_break_1_1 = set.tie_break.points_2 unless set.tie_break.nil?
        @form.tie_break_1_2 = set.tie_break.points_1 unless set.tie_break.nil?
      end
    when 2
      if user_score_order
        @form.set_2_1 = set.games_1
        @form.set_2_2 = set.games_2
        @form.tie_break_2_1 = set.tie_break.points_1 unless set.tie_break.nil?
        @form.tie_break_2_2 = set.tie_break.points_2 unless set.tie_break.nil?
      else
        @form.set_2_1 = set.games_2
        @form.set_2_2 = set.games_1
        @form.tie_break_2_1 = set.tie_break.points_2 unless set.tie_break.nil?
        @form.tie_break_2_2 = set.tie_break.points_1 unless set.tie_break.nil?
      end
    when 3
      if user_score_order
        @form.set_3_1 = set.games_1
        @form.set_3_2 = set.games_2
        @form.tie_break_3_1 = set.tie_break.points_1 unless set.tie_break.nil?
        @form.tie_break_3_2 = set.tie_break.points_2 unless set.tie_break.nil?
      else
        @form.set_3_1 = set.games_2
        @form.set_3_2 = set.games_1
        @form.tie_break_3_1 = set.tie_break.points_2 unless set.tie_break.nil?
        @form.tie_break_3_2 = set.tie_break.points_1 unless set.tie_break.nil?
      end
    end
  end
 end

end
