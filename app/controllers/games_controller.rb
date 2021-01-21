class GamesController < ApplicationController
  before_action :set_players_and_clubs_and_courts_and_rounds, only: [:new, :create, :edit, :update]
  before_action :set_game, only: [:edit, :update]

  def index
    @max_date = Game.maximum(:date).year
    @min_date = Game.minimum(:date).year

    @games = PlayerGamesQuery.new(policy_scope(Game), current_user.player).get_games(@max_date)
    
    #@games = structured_output(current_user.player, current_user)


    @games = GameIndexDecorator.new(@games)
    
  end

  def new
    @form = GameForm.new
    populate_tournament if session[:tournament_id]
    authorize @form
  end

  def create
    @form = GameForm.new(game_form_params)

    authorize @form
    if @form.save(game_form_params, current_user)
      if params[:create_and_add]
        session[:tournament_id] = @form.tournament_id
        redirect_to new_game_path 
      else
        redirect_to games_path 
      end
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

  def populate_tournament
    tournament = Tournament.includes(:club, :category).find(session[:tournament_id])
    session.delete(:tournament_id)
    @form.tournament_id = tournament.id
    @form.club = tournament.club.id
    @form.category = tournament.category_id
    refresh_cascading_dropdowns
  end

  def refresh_cascading_dropdowns
    query = CascadingDropdownsQuery.new(policy_scope(Tournament), @form.club, current_user.player, false)
    @categories = query.select_categories unless @form.club.blank?
    @tournament_dates = query.select_dates(@form.category) unless @form.category.blank?
  end

  def structured_output(player, current_user)
    structured_output = []
    selected_player_id = player.id
    current_user_player_id = current_user.player.id
    @games.each do |tournament_key, tournament_value| 
      structured_output << { club: tournament_value.first.tournament.club.name,
                             category: tournament_value.first.tournament.category.category,
                             dates: TournamentDecorator.new(tournament_value.first.tournament).tournament_date,
                             games: []
                           }
      tournament_value.sort_by{|tournament| [tournament.date ? 1 : 0, tournament.date] }.reverse.each do |game|
        game_hash = {}
        user_score_order = (game.player_id.nil? ? GamePlayerOrderService.maintain?(game, selected_player_id) : (selected_player_id == game.player_id))
        opponent = game.players.find{|player| player.id != selected_player_id}
        opponent = PlayerDecorator.new(opponent) if opponent
        game_hash[:player_name] = PlayerDecorator.new(player).player_description
        game_hash[:game] = game
        game_hash[:date] = game.date
        game_hash[:status] = game.status
        game_hash[:victory] = (game.game_players.find{|player| player.player_id == selected_player_id}.victory ? 'Victoire' : 'Défaite')
        if game.game_players.find{|player| player.player_id == current_user_player_id}
          game_hash[:validated] = game.game_players.find{|player| player.player_id == current_user_player_id}.validated
        end
        game_hash[:name] = (opponent ? opponent.full_name : 'N.A.')
        byebug
        game_hash[:ranking] = (opponent ? game.game_players.find{|player| player_id.id = selected_player_id}.ranking.name : 'N.A.')
        game_hash[:score] = GameDecorator.new(game).game_score(selected_player_id)
        structured_output[-1][:games] << game_hash
      end
    end
    structured_output
  end
end
