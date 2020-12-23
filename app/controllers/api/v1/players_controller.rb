class Api::V1::PlayersController < Api::V1::BaseController
  before_action :set_player, only: [ :show ]

  def index
    if params[:query].present?
      @players = policy_scope(Player).includes(ranking_histories: :ranking).search_by_name_and_affiliation_number(params[:query]).first(10)
    else
      @players = policy_scope(Player).includes(ranking_histories: :ranking)
    end
    render json: { error: "Couldn't find #{params[:query].titleize}"} , status: :not_found if (@players.size == 0)
  end

  def show
  end

  private

  def set_player
    @player = Player.find_by_affiliation_number!(params[:id])
    authorize @player # For Pundit
  end
end