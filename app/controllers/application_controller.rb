class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Instance Method
  
  def after_sign_in_path_for(resource)
    games_path
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def get_player
    if params[:player].present?
      if params[:player].scan(/\((\d+)\)/).blank?
        player = nil
      else
        player = Player.includes(ranking_histories: :ranking).find_by_affiliation_number(params[:player].scan(/\((\d+)\)/)[0][0])
      end
    else
      player = Player.includes(ranking_histories: :ranking).find(current_user.player.id)
    end
  end
  
end
