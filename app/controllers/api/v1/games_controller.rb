class Api::V1::GamesController < Api::V1::BaseController
    before_action :set_player, only: [ :show ]
  
    def index
      if params[:year].present?
        query = 'game_players.player_id = ? AND extract(year from games.date) = ?'
        games = policy_scope(Game).includes(:players, game_players: :ranking, game_sets: :tie_break, tournament: [:club, :category])
                                .joins(:game_players, :tournament).merge(Tournament.order(start_date: :desc)).where(query, current_user.player.id, params[:year])
                                .group_by(&:tournament_id)
      else
        query = 'game_players.player_id = ?'
        games = policy_scope(Game).includes(:players, game_players: :ranking, game_sets: :tie_break, tournament: [:club, :category])
                                .joins(:game_players, :tournament).merge(Tournament.order(start_date: :desc)).where(query, current_user.player.id)
                                .group_by(&:tournament_id)
      end

      games = GamesIndexDecorator.new(games)
      @structured_output = games.structured_output(current_user)

      if (@structured_output.size == 0) 
        render(json: { error: "Couldn't find date for #{params[:year]}"} , status: :not_found) 
      else
        render(json: { html_data: render_to_string(partial: "games/games_info.html.erb", locals: { structured_output: @structured_output })})
      end
    end
  
    def show
    end
  
    private
  
    def set_player
      @player = Player.find_by_affiliation_number!(params[:id])
      authorize @player # For Pundit
    end
  end