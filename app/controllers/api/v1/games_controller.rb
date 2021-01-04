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
      @structured_output = []
      user_player_id = current_user.player.id
      games.each do |tournament_key, tournament_value| 
        @structured_output << {club: tournament_value.first.tournament.club.name,
                            category: tournament_value.first.tournament.category.category,
                            dates: tournament_value.first.tournament.tournament_date,
                            games: []
                            }
        tournament_value.sort_by{|tournament| [tournament.date ? 1 : 0, tournament.date] }.reverse.each do |game|
          game_hash = {}
          user_score_order = (game.player_id.nil? ? game.check_user_order(user_player_id) : (user_player_id == game.player_id))
      
          opponent = game.players.find{|player| player.id != user_player_id}
          game_hash[:game] = game
          game_hash[:date] = game.date
          game_hash[:status] = game.status
          game_hash[:victory] = (game.game_players.find{|player| player.player_id == user_player_id}.victory ? "Victoire" : "Défaite")
          game_hash[:validated] = game.game_players.find{|player| player.player_id == user_player_id}.validated
          game_hash[:name] = (opponent ? opponent.full_name : "N.A.")
          game_hash[:ranking] = (opponent ? game.game_players.find{|player| player.id != user_player_id}.ranking.name : "N.A.")
          game_hash[:score] = game.game_score(user_player_id)
          @structured_output[-1][:games] << game_hash
        end
      end

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