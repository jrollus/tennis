class PlayersController < ApplicationController
  def stats
      @query = PlayersQuery.new(current_user.player)
      authorize @query
  end
end
  