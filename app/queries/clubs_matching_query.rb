class ClubsMatchingQuery
  def initialize(player, type='single')
    @player = player
    @type = type
  end

  def get_clubs_matching
    query = 'categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max AND category_rankings.ranking_id = ?'
    @clubs = Club.joins(tournaments: {category: :category_rankings})
                 .where(query, @player.gender, @type, @player.age, @player.age, @player.ranking_histories.last.ranking.id).uniq.sort
  end
end