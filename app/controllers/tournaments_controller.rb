class TournamentsController < ApplicationController
    before_action :set_tournament, only: [:edit, :update]

    def index
      if params[:club].present?
        query = CascadingDropdownsQuery.new(policy_scope(Tournament), params[:club], current_user.player, true)
        if params[:type] == 'club' && params[:club].present?
          @options_list = query.select_categories(params[:type])
        elsif params[:type] == 'category' && params[:category].present?
          @options_list = query.select_dates(params[:category], params[:type])
        else
          render json: { error: "The output type must be specified"} , status: :not_found
          return
        end
        @options_list.first.gsub!(/'\d+'/, '\0 selected') if @options_list.size == 1
        @options_list.unshift("<option value></option>")
        (@options_list.size == 1) ? (render json: { error: "Couldn't find #{params[:type].capitalize}"} , status: :not_found) : (render json: @options_list)
      else
        skip_policy_scope
        render json: { error: "The output type must be specified"} , status: :not_found
      end
    end
    
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
    
    def validations
      @tournaments = policy_scope(Tournament).includes(:club, :category).where(tournaments: {validated: false})
      authorize @tournaments
    end
  
    def validate
      @tournament = Tournament.find(params[:tournament_id])
      authorize @tournament
      @tournament.update(validated: true)
  
      redirect_back(fallback_location: tournaments_validations_path)
    end

    
    private
  
    def tournament_params
      params.require(:tournament).permit(:id, :club_id, :category_id, :start_date, :end_date, :nbr_participants)
    end
  
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end
  end