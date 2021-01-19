class Api::V1::PlayersController < Api::V1::BaseController
  before_action :set_player, only: [ :show ]

  def index
    if params[:query].present?
      @players = policy_scope(Player).includes(ranking_histories: :ranking).search_by_name_and_affiliation_number(params[:query]).first(10)
    else
      @players = policy_scope(Player).includes(ranking_histories: :ranking)
    end
    @players = @players.map{|player| PlayerDecorator.new(player)}
    render json: { error: "Couldn't find #{params[:query].titleize}"} , status: :not_found if (@players.size == 0)
  end

  def show
    authorize @player
  end

  def stats
    @player = get_player
    if @player
      authorize @player
      @year = (params[:year].present? ? params[:year] : nil)
      @query = PlayersQuery.new(@player)
      render(json: { html_data: render_to_string(partial: 'players/stats_info.html.erb')})
    else
      skip_authorization
      render(json: { error: "Couldn't find data for player: #{params[:player]}}"} , status: :not_found)
    end
  end

  private

  def set_player
    @player = Player.find_by_affiliation_number!(params[:id])
  end

  def get_player
    if params[:player].present?
      if params[:player].scan(/\((\d+)\)/).blank?
        player = nil
      else
        player = Player.find_by_affiliation_number(params[:player].scan(/\((\d+)\)/)[0][0])
      end
    else
      player = current_user.player
    end
  end
end