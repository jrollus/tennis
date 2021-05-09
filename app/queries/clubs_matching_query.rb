class ClubsMatchingQuery
  def initialize(player, type='single')
    @player = player
    @type = type
  end

  def get_clubs_matching
    query = 'categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND
             ? < categories.age_max AND category_rankings.ranking_id = ? AND tournaments.start_date >= ?'
    @clubs = Club.joins(tournaments: {category: :category_rankings})
                 .where(query, @player.gender, @type, @player.age, @player.age, @player.ranking_histories.max_by{|ranking| ranking.start_date}.ranking.id, 12.months.ago).uniq.sort
  end
end