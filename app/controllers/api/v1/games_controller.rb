class Api::V1::GamesController < Api::V1::BaseController
  def index
    query = PlayerGamesQuery.new(policy_scope(Game), current_user.player)
    games = GameIndexDecorator.new(params[:year].present? ? query.get_games(params[:year]) : query.get_games)
    @structured_output = games.structured_output(current_user)

    if (@structured_output.size == 0) 
      render(json: { error: "Couldn't find date for #{params[:year]}"} , status: :not_found) 
    else
      render(json: { html_data: render_to_string(partial: 'games/games_info.html.erb', locals: { structured_output: @structured_output })})
    end
  end
end