class TournamentsController < ApplicationController
    before_action :set_tournament, only: [:edit, :update]
  
    def new
      @tournament = Tournament.new
      authorize @tournament
    end
  
    def create
      @tournament = Tournament.new(tournament_params)
      @tournament.player_id  = current_user.player.id
      @tournament.validated = (current_user.admin ? current_user.admin : false)
      authorize @tournament
      if @tournament.save
        redirect_to games_path
      else
        render :new
      end
    end
  
    def edit
      authorize @tournament
    end
  
    def update
      authorize @tournament
      if @tournament.update(tournament_params)
        redirect_to games_path
      else
        render :edit
      end
    end
    
    private
  
    def tournament_params
      params.require(:tournament).permit(:id, :club_id, :category_id, :start_date, :end_date, :nbr_participants)
    end
  
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end
  end