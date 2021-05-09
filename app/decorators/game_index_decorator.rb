class GameIndexDecorator < SimpleDelegator
    def model
      __getobj__
    end

    def structured_output(player, current_user, game_type)
      structured_output = []
      if player.present?
        selected_player_id = player.id
        current_user_player_id = current_user.player.id
        self.each do |k, v| 
          if game_type == 'tournament'
            structured_output << { club: v.first.tournament.club.name,
                                  category: v.first.tournament.category.category,
                                  dates: TournamentDecorator.new(v.first.tournament).tournament_date,
                                  games: []
                                }
          elsif game_type == 'interclub'
            structured_output << { division: v.first.interclub.division.name,
                                  games: []
                                }
          end
          
          v.each do |game|
            game_hash = {}
            user_score_order = (game.player_id.nil? ? GamePlayerOrderService.maintain?(game, selected_player_id) : (selected_player_id == game.player_id))
            opponent = game.players.find{|player| player.id != selected_player_id}
            opponent = PlayerDecorator.new(opponent) if opponent
            game_hash[:player_name] = PlayerDecorator.new(player).player_description
            game_hash[:game] = game
            game_hash[:date] = game.date
            game_hash[:status] = game.status
            if game_type == 'tournament'
              game_hash[:round] = game.round.name
            end
            game_hash[:victory] = game.game_players.find{|player| player.player_id == selected_player_id}.victory
            if game.game_players.find{|player| player.player_id == current_user_player_id}
              game_hash[:validated] = game.game_players.find{|player| player.player_id == current_user_player_id}.validated
            end
            game_hash[:name] = (opponent ? opponent.full_name : 'N.A.')
            game_hash[:ranking] = (opponent ? game.game_players.find{|player| player.player_id != selected_player_id}.ranking.name : 'N.A.')
            game_hash[:score] = GameDecorator.new(game).game_score(selected_player_id)
            structured_output[-1][:games] << game_hash
          end
        end
      end
      structured_output
    end

end