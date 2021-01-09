class GamesController < ApplicationController
  before_action :set_clubs_and_courts, only: [:new, :create, :edit, :update]
  before_action :set_game, only: [:edit, :update]

  def index
    @max_date = Game.maximum(:date).year
    @min_date = Game.minimum(:date).year

    query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
    games = policy_scope(Game).includes(:players, game_players: :ranking, game_sets: :tie_break, tournament: [:club, :category])
                               .joins(:game_players, :tournament).merge(Tournament.order(start_date: :desc)).where(query, current_user.player.id, @max_date)
                               .group_by(&:tournament_id)

    @structured_output = []
    user_player_id = current_user.player.id
    games.each do |tournament_key, tournament_value| 
      @structured_output << {club: tournament_value.first.tournament.club.name,
                           category: tournament_value.first.tournament.category.category,
                           dates: tournament_value.first.tournament.tournament_date,
                           games: []
                          }
      tournament_value.sort_by{|tournament| [tournament.date ? 1 : 0, tournament.date] }.reverse.each do |game|
        game_hash = {}
        user_score_order = (game.player_id.nil? ? game.check_user_order(user_player_id) : (user_player_id == game.player_id))
    
        opponent = game.players.find{|player| player.id != user_player_id}
        game_hash[:game] = game
        game_hash[:date] = game.date
        game_hash[:status] = game.status
        game_hash[:victory] = (game.game_players.find{|player| player.player_id == user_player_id}.victory ? "Victoire" : "Défaite")
        game_hash[:validated] = game.game_players.find{|player| player.player_id == user_player_id}.validated
        game_hash[:name] = (opponent ? opponent.full_name : "N.A.")
        game_hash[:ranking] = (opponent ? game.game_players.find{|player| player.id != user_player_id}.ranking.name : "N.A.")
        game_hash[:score] = game.game_score(user_player_id)
        @structured_output[-1][:games] << game_hash
      end
    end
  end

  def show
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
    params.require(:game_form).permit(:club, :category, :tournament_id, :player_id, :court_type_id, :date, :status, :round, :court_type, :indoor, :opponent, :victory, :match_points_saved,
                                      game_sets_attributes: [:id, :set_number, :games_1, :games_2, :_destroy, tie_break_attributes: [:id, :points_1, :points_2, :_destroy]])
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
                  .where(query,  @form.club, current_user.player.gender, 'single', current_user.player.get_age, current_user.player.get_age)
    tournaments.map{|tournament| [tournament.category.category, tournament.category.id]}.uniq.sort {|a,b| a[1] <=> b[1]}
  end

  def select_dates
    query = "tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max AND tournaments.category_id = ?"
    tournaments = Tournament.includes(:category).joins(:category)
                  .where(query, @form.club, current_user.player.gender,'single', current_user.player.get_age, current_user.player.get_age, @form.category)
    tournaments.map{|tournament| ["#{tournament.start_date.strftime("%d/%m/%Y")} - #{tournament.end_date.strftime("%d/%m/%Y")}", tournament.id]}.uniq.sort {|a,b| a[1] <=> b[1]}
  end

  def refresh_cascading_dropdowns
    @categories = select_categories unless @form.club.blank?
    @tournament_dates = select_dates unless @form.category.blank?
    @round_selected = @form.round
  end
end
