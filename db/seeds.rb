require 'csv'

# Tournament Categories
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
RankingEntry.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('ranking_entries')
filepath = 'db/data/ranking_entries.csv'
entries = []
CSV.foreach(filepath, headers: true) do |row|
    entries << row.to_hash
end
RankingEntry.import(entries)

# Nbr Participant Rules
NbrParticipantRule.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('nbr_participant_rules')

filepath = 'db/data/nbr_participant_rules.csv'
rules = []
CSV.foreach(filepath, headers: true) do |row|
    rules << row.to_hash
end
NbrParticipantRule.import(rules)

# Clubs
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
ActiveRecord::Base.connection.reset_pk_sequence!('courts')

filepath = 'db/data/courts.csv'
courts = []
CSV.foreach(filepath, headers: true) do |row|
    courts << row.to_hash
end
Court.import(courts)

# Tournament
ActiveRecord::Base.connection.reset_pk_sequence!('tournaments')

filepath = 'db/data/tournaments.csv'
tournaments = []
CSV.foreach(filepath, headers: true) do |row|
    tournaments << row.to_hash
end
Tournament.import(tournaments)