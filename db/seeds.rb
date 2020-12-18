require 'csv'

# Tournament Categories
puts "Seeding Tournament Categories"
GamePlayer.destroy_all
Game.destroy_all
Tournament.destroy_all
Category.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('categories')

filepath = 'db/data/tournament_categories.csv'
categories = []
CSV.foreach(filepath, headers: true) do |row|
    categories << row.to_hash
end
Category.import(categories)

# Ranking Entries
puts "Seeding Ranking Entries"
RankingHistory.destroy_all
Ranking.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('rankings')
filepath = 'db/data/ranking_entries.csv'
entries = []
CSV.foreach(filepath, headers: true) do |row|
    entries << row.to_hash
end
Ranking.import(entries)

# Nbr Participant Rules
puts "Seeding Participant Rules"
NbrParticipantRule.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('nbr_participant_rules')

filepath = 'db/data/nbr_participant_rules.csv'
rules = []
CSV.foreach(filepath, headers: true) do |row|
    rules << row.to_hash
end
NbrParticipantRule.import(rules)

# Clubs
puts "Seeding Clubs"
Player.destroy_all
Court.destroy_all
Club.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('clubs')

filepath = 'db/data/clubs.csv'
clubs = []
CSV.foreach(filepath, headers: true) do |row|
    clubs << row.to_hash
end
Club.import(clubs)

# Courts
puts "Seeding Courts"
ActiveRecord::Base.connection.reset_pk_sequence!('courts')

filepath = 'db/data/courts.csv'
courts = []
CSV.foreach(filepath, headers: true) do |row|
    courts << row.to_hash
end
Court.import(courts)

# Tournament
puts "Seeding Tournament"
ActiveRecord::Base.connection.reset_pk_sequence!('tournaments')

filepath = 'db/data/tournaments.csv'
tournaments = []
CSV.foreach(filepath, headers: true) do |row|
    tournaments << row.to_hash
end
Tournament.import(tournaments)

# Player
puts "Seeding Player"
ActiveRecord::Base.connection.reset_pk_sequence!('players')

filepath = 'db/data/players.csv'
players = []
CSV.foreach(filepath, headers: true) do |row|
    players << row.to_hash
end
Player.import(players)

# Ranking History
User.destroy_all
puts "Seeding Ranking History"
ActiveRecord::Base.connection.reset_pk_sequence!('ranking_histories')

filepath = 'db/data/rankings_history.csv'
ranking_histories = []
CSV.foreach(filepath, headers: true) do |row|
    ranking_histories << row.to_hash
end
RankingHistory.import(ranking_histories)

# Game
puts "Seeding Game"
ActiveRecord::Base.connection.reset_pk_sequence!('games')

filepath = 'db/data/games.csv'
games = []
CSV.foreach(filepath, headers: true) do |row|
    games << row.to_hash
end
Game.import(games)

# Game Players
puts "Seeding Game Player"

ActiveRecord::Base.connection.reset_pk_sequence!('game_players')

filepath = 'db/data/game_players.csv'
game_players = []
CSV.foreach(filepath, headers: true) do |row|
    game_players << row.to_hash
end
GamePlayer.import(game_players)