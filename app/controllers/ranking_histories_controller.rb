class RankingHistoriesController < ApplicationController
  before_action :set_ranking_history, only: [:edit, :update]

  def index
    @max_date = Game.maximum(:date).year
    @min_date = Game.minimum(:date).year
    @ranking_histories = policy_scope(RankingHistory)
  end

  def edit
    authorize @ranking_history
  end

  def update
    authorize @ranking_history
    if @ranking_history.update(ranking_history_params)
      redirect_to ranking_histories_path
    else
      render :edit
    end
  end
  
  private

  def ranking_history_params
    params.require(:ranking_history).permit(:id, :year, :year_number, :start_date, :end_date, :ranking_id)
  end

  def set_ranking_history
    @ranking_history = RankingHistory.find(params[:id])
  end
end
