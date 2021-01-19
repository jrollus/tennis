class PlayersController < ApplicationController
  before_action :set_player, only: [:edit, :update]

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
    @max_date = Game.maximum(:date).year
    @min_date = Game.minimum(:date).year
    @year = @max_date
    @player = current_user.player 
    @query = PlayersQuery.new(@player)
    authorize @player
  end

  private

  def player_params
    params.require(:player).permit(:id, :affiliation_number, :first_name, :last_name, :club_id, :birthdate, :gender, :dominant_hand,
                                   ranking_histories_attributes: [:id, :ranking_id, :year, :year_number, :start_date, :end_date])
  end

  def set_player
    @player = Player.find(params[:id])
  end
end
  