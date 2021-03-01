require 'csv'

# Destroy
puts "Destroying Existing Data"
GamePlayer.destroy_all
GameSet.destroy_all
TieBreak.destroy_all
Game.destroy_all
Interclub.destroy_all
DivisionRanking.destroy_all
Division.destroy_all
CategoryRound.destroy_all
Round.destroy_all
Tournament.destroy_all
CategoryRanking.destroy_all
Category.destroy_all
RankingHistory.destroy_all
Ranking.destroy_all
NbrParticipantRule.destroy_all
Player.destroy_all
Court.destroy_all
Club.destroy_all
CourtType.destroy_all
User.destroy_all

# Division
puts "Seeding Divisions"
ActiveRecord::Base.connection.reset_pk_sequence!('divisions')

filepath = 'db/data/divisions.csv'
divisions = []
CSV.foreach(filepath, headers: true) do |row|
    divisions << row.to_hash
end
Division.import(divisions)

# Tournament Categories
puts "Seeding Tournament Categories"
ActiveRecord::Base.connection.reset_pk_sequence!('categories')

filepath = 'db/data/tournament_categories.csv'
categories = []
CSV.foreach(filepath, headers: true) do |row|
    categories << row.to_hash
end
Category.import(categories)

# Ranking Entries
puts "Seeding Ranking Entries"
ActiveRecord::Base.connection.reset_pk_sequence!('rankings')
filepath = 'db/data/ranking_entries.csv'
entries = []
CSV.foreach(filepath, headers: true) do |row|
    entries << row.to_hash
end
Ranking.import(entries)

# Division Rankings
puts "Seeding Division Rankings"
ActiveRecord::Base.connection.reset_pk_sequence!('division_rankings')

filepath = 'db/data/division_rankings.csv'
division_rankings = []
CSV.foreach(filepath, headers: true) do |row|
    division_rankings << row.to_hash
end
DivisionRanking.import(division_rankings)

# Interclubs
puts "Seeding Interclubs"
ActiveRecord::Base.connection.reset_pk_sequence!('interclubs')

filepath = 'db/data/interclub.csv'
interclubs = []
CSV.foreach(filepath, headers: true) do |row|
    interclubs << row.to_hash
end
Interclub.import(interclubs)

# Category Rankings
puts "Seeding Category Rankings"
ActiveRecord::Base.connection.reset_pk_sequence!('category_rankings')

filepath = 'db/data/category_rankings.csv'
categorie_rankings = []
CSV.foreach(filepath, headers: true) do |row|
    categorie_rankings << row.to_hash
end
CategoryRanking.import(categorie_rankings)

# Nbr Participant Rules
puts "Seeding Participant Rules"
ActiveRecord::Base.connection.reset_pk_sequence!('nbr_participant_rules')

filepath = 'db/data/nbr_participant_rules.csv'
rules = []
CSV.foreach(filepath, headers: true) do |row|
    rules << row.to_hash
end
NbrParticipantRule.import(rules)

# Clubs
puts "Seeding Clubs"
ActiveRecord::Base.connection.reset_pk_sequence!('clubs')

filepath = 'db/data/clubs.csv'
clubs = []
CSV.foreach(filepath, headers: true) do |row|
    clubs << row.to_hash
end
Club.import(clubs)

# Court Types

puts "Seeding Court Types"
ActiveRecord::Base.connection.reset_pk_sequence!('court_types')

filepath = 'db/data/court_types.csv'
court_types = []
CSV.foreach(filepath, headers: true) do |row|
    court_types << row.to_hash
end
CourtType.import(court_types)

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
Tournament.import(tournaments, validate: false)

# Player
puts "Seeding Player"
ActiveRecord::Base.connection.reset_pk_sequence!('players')

filepath = 'db/data/players.csv'
players = []
CSV.foreach(filepath, headers: true) do |row|
    players << row.to_hash
end
Player.import(players, validate: false)

# Ranking History
puts "Seeding Ranking History"
ActiveRecord::Base.connection.reset_pk_sequence!('ranking_histories')

filepath = 'db/data/rankings_history.csv'
ranking_histories = []
CSV.foreach(filepath, headers: true) do |row|
    ranking_histories << row.to_hash
end
RankingHistory.import(ranking_histories)

# Rounds
puts "Seeding Round"
ActiveRecord::Base.connection.reset_pk_sequence!('rounds')

filepath = 'db/data/rounds.csv'
rounds = []
CSV.foreach(filepath, headers: true) do |row|
    rounds << row.to_hash
end
Round.import(rounds)

# Game
puts "Seeding Game"
ActiveRecord::Base.connection.reset_pk_sequence!('games')

filepath = 'db/data/games.csv'
games = []
CSV.foreach(filepath, headers: true) do |row|
    games << row.to_hash
end
Game.import(games)

# Sets
puts "Seeding GameSet"
ActiveRecord::Base.connection.reset_pk_sequence!('game_sets')

filepath = 'db/data/sets.csv'
sets = []
CSV.foreach(filepath, headers: true) do |row|
    sets << row.to_hash
end
GameSet.import(sets)

# Game Players
puts "Seeding GamePlayer"
ActiveRecord::Base.connection.reset_pk_sequence!('game_players')

filepath = 'db/data/game_players.csv'
game_players = []
CSV.foreach(filepath, headers: true) do |row|
    game_players << row.to_hash
end
GamePlayer.import(game_players)

# Rounds
puts "Seeding CategoryRound"
ActiveRecord::Base.connection.reset_pk_sequence!('category_rounds')

filepath = 'db/data/category_rounds.csv'
category_rounds = []
CSV.foreach(filepath, headers: true) do |row|
    category_rounds << row.to_hash
end
CategoryRound.import(category_rounds)