class Api::V1::GamesController < Api::V1::BaseController
  def index
    player = get_player
    if player
      query = PlayerGamesQuery.new(policy_scope(Game), player)
      games = GameIndexDecorator.new(params[:year].present? ? query.get_games(params[:year]) : query.get_games)
      @structured_output = games.structured_output(player, current_user)

      if (@structured_output.size == 0) 
        render(json: { error: "Couldn't find data for year: #{params[:year]} and player: #{params[:player]}"} , status: :not_found) 
      else
        render(json: { html_data: render_to_string(partial: 'games/games_info.html.erb', locals: { structured_output: @structured_output })})
      end

    else
      skip_policy_scope
      render(json: { error: "Couldn't find data for player: #{params[:player]}}"} , status: :not_found) 
    end

  end

  private

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