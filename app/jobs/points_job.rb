class PointsJob < ApplicationJob
  queue_as :default

  def perform(player, date)
    puts "Attempting to compute points for player with id: #{player.id}"
    ranking_history = player.ranking_histories.find{|ranking| date.between?(ranking.start_date, ranking.end_date)}
    if ranking_history.present?
      games = PlayerPointsQuery.new(Game.all, player).get_games(ranking_history.start_date, ranking_history.end_date)
      nbr_participant_rules = NbrParticipantRule.all
      points_by_tournament = []
      if games.present?
        games.each do |tournament_key, tournament_value| 
          points = 0
          unless (games.size == 1) && !tournament_value.first.game_players.find{|game_player| game_player.player_id == player.id}.victory
            points += tournament_value.size * 2
            last_round_game = tournament_value.min{|a, b| a.round_id <=> b.round_id}
            round_id = last_round_game.round_id
            round_id = 1 if (round_id == 2)  && last_round_game.game_players.find{|game_player| game_player.player_id == player.id}.victory
            nbr_participants = tournament_value.first.tournament.nbr_participants
            weight = nbr_participant_rules.find{|e| nbr_participants.between?(e.lower_bound, e.upper_bound)}.weight
            points += tournament_value.first.tournament.category.category_rounds.find{|category_round| category_round.round_id == round_id}.points * weight  
            tournament_value.each do |game|
              victory = game.game_players.find{|game_player| game_player.player_id == player.id}.victory
              opponent =  game.game_players.find{|game_player| game_player.player_id != player.id}
              if opponent
                if opponent.ranking
                  points += opponent.ranking.points if victory
                end
              end
            end
          end
          points_by_tournament << points
        end
        player_points = points_by_tournament.sort.reverse.take(6).sum(0.0) / points_by_tournament.take(6).size
        player_points *= (1 - ((6 - points_by_tournament.size) * 0.04)) if points_by_tournament.size < 6
      else
        player_points = 0
      end
      ranking_history.update(points: player_points)
      puts "Player points: #{player_points}"
    end
  end
end
