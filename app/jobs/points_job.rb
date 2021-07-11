class PointsJob < ApplicationJob
  queue_as :default

  MIN_NUMBER_COMPETITIONS = 6
  COMPETITION_PENALTY = 0.04
  MIN_NUMBER_INTERCLUB_GAMES = 3
  INTERCLUB_PENALTY = 0.20

  def perform(player, date)
    puts "Attempting to compute points for player with id: #{player.id}"
    ranking_history = player.ranking_histories.find{|ranking| date.between?(ranking.start_date, ranking.end_date)}
    if ranking_history.present?
      query = PlayerPointsQuery.new(Game.all, player)

      # Tournaments
      games = query.get_tournament_games(ranking_history.start_date, ranking_history.end_date)
      nbr_participant_rules = NbrParticipantRule.all
      points_by_competition = []
      if games.present?
        games.each do |tournament_key, tournament_value| 
          points = 0
          unless (tournament_value.size == 1) && !tournament_value.first.game_players.find{|game_player| game_player.player_id == player.id}.victory
            points += tournament_value.size * 2
            last_round_game = tournament_value.min{|a, b| a.round_id <=> b.round_id}
            round_id = last_round_game.round_id
            round_id -= 1 if last_round_game.game_players.find{|game_player| game_player.player_id == player.id}.victory
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
            points_by_competition << points
          end
        end
      end

      # Interclubs
      games = query.get_interclub_games(ranking_history.start_date, ranking_history.end_date)

      if games.present?
        interclub_game_points = []
        games.each do |interclub_key, interclub_value|
          interclub_value.each do |game|
            victory = game.game_players.find{|game_player| game_player.player_id == player.id}.victory
            if victory
              opponent =  game.game_players.find{|game_player| game_player.player_id != player.id}
              if opponent
                if opponent.ranking
                  interclub_game_points << game.interclub.division.division_rankings.find{|division_ranking| division_ranking.ranking_id == opponent.ranking.id}.points
                end
              end
            end
          end
        end

        if interclub_game_points.present?
          interclub_points = interclub_game_points.sort.reverse.take(MIN_NUMBER_INTERCLUB_GAMES).sum(0.0) / interclub_game_points.take(MIN_NUMBER_INTERCLUB_GAMES).size
          interclub_points *= (1 - ((MIN_NUMBER_INTERCLUB_GAMES - interclub_game_points.size) * INTERCLUB_PENALTY)) if interclub_game_points.size < MIN_NUMBER_INTERCLUB_GAMES
          points_by_competition << interclub_points
        end
      end

      # Total Points
      player_points = points_by_competition.sort.reverse.take(MIN_NUMBER_COMPETITIONS).sum(0.0) / points_by_competition.take(MIN_NUMBER_COMPETITIONS).size
      player_points *= (1 - ((MIN_NUMBER_COMPETITIONS - points_by_competition.size) * COMPETITION_PENALTY)) if points_by_competition.size < MIN_NUMBER_COMPETITIONS
      player_points = 0 if player_points.nan?
      ranking_history.update(points: player_points)
      puts "Player points: #{player_points}"
    end
  end
end
