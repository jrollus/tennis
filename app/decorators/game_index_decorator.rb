class GameIndexDecorator < SimpleDelegator
    def model
      __getobj__
    end

    def structured_output(player, current_user)
      structured_output = []
      selected_player_id = player.id
      current_user_player_id = current_user.player.id
      self.each do |tournament_key, tournament_value| 
        structured_output << { club: tournament_value.first.tournament.club.name,
                               category: tournament_value.first.tournament.category.category,
                               dates: TournamentDecorator.new(tournament_value.first.tournament).tournament_date,
                               games: []
                             }
        tournament_value.sort_by{|tournament| [tournament.date ? 1 : 0, tournament.date] }.reverse.each do |game|
          game_hash = {}
          user_score_order = (game.player_id.nil? ? GamePlayerOrderService.maintain?(game, selected_player_id) : (selected_player_id == game.player_id))
          opponent = game.players.find{|player| player.id != selected_player_id}
          opponent = PlayerDecorator.new(opponent) if opponent
          game_hash[:player_name] = PlayerDecorator.new(player).player_description
          game_hash[:game] = game
          game_hash[:date] = game.date
          game_hash[:status] = game.status
          game_hash[:round] = game.round.name
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
      structured_output
    end

end