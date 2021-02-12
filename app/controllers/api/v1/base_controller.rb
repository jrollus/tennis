class Api::V1::BaseController < ActionController::API
    include Pundit
  
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
  
    rescue_from Pundit::NotAuthorizedError,   with: :user_not_authorized
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
  
    private
  
    def user_not_authorized(exception)
      render json: {
        error: "Unauthorized #{exception.policy.class.to_s.underscore.camelize}.#{exception.query}"
      }, status: :unauthorized
    end
  
    def not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end

    def get_player
      if params[:player].present?
        if params[:player].scan(/\((\d+)\)/).blank?
          player = nil
        else
          player = Player.includes(ranking_histories: :ranking).find_by_affiliation_number(params[:player].scan(/\((\d+)\)/)[0][0])
        end
      else
        player = @user_player
      end
    end
  end