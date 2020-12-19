class Api::V1::PlayersController < Api::V1::BaseController
  before_action :set_player, only: [ :show ]

  def show
  end

  private

  def set_player
    @player = Player.find_by_affiliation_number!(params[:id])
    authorize @player # For Pundit
  end
end