class PlayersController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  before_action :set_player, only: [:edit, :update]
  before_action :set_player_ajax, only: [:show]

  def index
    if params[:search].present?
      if params[:gender].present?
        @players = policy_scope(Player).includes(ranking_histories: :ranking).search_by_name_and_affiliation_number(params[:search])
                                       .select{|player| player.gender == params[:gender]}.first(10)
      else  
        @players = policy_scope(Player).includes(ranking_histories: :ranking).search_by_name_and_affiliation_number(params[:search]).first(10)
      end
    else
      @players = policy_scope(Player).includes(ranking_histories: :ranking)
    end
    @players = @players.map{|player| PlayerDecorator.new(player)}
    render json: { error: "Couldn't find #{params[:query].titleize}"} , status: :not_found if (@players.size == 0)
  end

  def show
    authorize @player
  end
  
  def new
    @player = Player.new
    @player.ranking_histories.build
    @year_nbr_dates = YearDatesService.get_year_nbr_dates
    authorize @player
  end

  def create
    @player = Player.new(player_params)    
    @player.player_creator_id  = current_user.player.id
    @player.validated = (current_user.admin ? current_user.admin : false)
    @year_nbr_dates = YearDatesService.get_year_nbr_dates

    authorize @player
    if @player.save
      redirect_to games_path
    else
      render :new
    end
  end

  def edit
    authorize @player
  end

  def update
    authorize @player
    if @player.update(player_params)
      redirect_to games_path
    else
      render :edit
    end
  end

  def stats
    @player = get_player
    @user_player = Player.includes(ranking_histories: :ranking).find(current_user.player.id)
    authorize @user_player
    @query = PlayersQuery.new(@player)

    respond_to do |format|
      format.html { 
        @max_date = Game.maximum(:date).year
        @min_date = Game.minimum(:date).year
        @year = @max_date
      }
      format.json { 
        @year = (params[:year].present? ? params[:year] : nil)
        render(json: { html_data: render_to_string(partial: 'players/stats_info.html.erb')})
       }
    end 
  end

  def compare
    @user_player = Player.includes(ranking_histories: :ranking).find(current_user.player.id)
    @player = get_player
    authorize @user_player
    @query_user_player = PlayersQuery.new(@user_player)
    @query_player = PlayersQuery.new(@player)
    respond_to do |format|
      format.html { 
        @max_date = Game.maximum(:date).year
        @min_date = Game.minimum(:date).year
        @year = @max_date
      }
      format.json { 
        @year = (params[:year].present? ? params[:year] : nil)
        render(json: { html_data: render_to_string(partial: 'players/compare_info.html.erb')})
       }
    end 

  end

  def validations
    @players = policy_scope(Player).includes(:club, ranking_histories: :ranking).where(players: {validated: false})
    authorize @players
  end

  def validate
    @player = Player.find(params[:player_id])
    authorize @player
    @player.update(validated: true)

    redirect_back(fallback_location: players_validations_path)
  end

  private

  def player_params
    params.require(:player).permit(:id, :affiliation_number, :first_name, :last_name, :club_id, :birthdate, :gender, :dominant_hand,
                                   ranking_histories_attributes: [:id, :ranking_id, :year, :year_number, :start_date, :validated, :end_date])
  end

  def set_player
    @player = Player.find(params[:id])
  end

  def set_player_ajax
    @player = Player.find_by_affiliation_number!(params[:id])
  end
end
  