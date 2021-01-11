class ClubsMatchingQuery
  def initialize(player, type='single')
    @player = player
    @type = type
  end

  def get_clubs_matching
    query = 'categories.gender = ? AND categories.c_type = ? AND ? >= categories.age_min AND ? < categories.age_max'
    @clubs = Club.joins(tournaments: :category).where(query, @player.gender, @type, @player.age, @player.age).uniq.sort
  end
end