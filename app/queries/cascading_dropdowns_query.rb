class CascadingDropdownsQuery
  def initialize(tournament, club, player, ajax, type='single')
    @tournament = tournament
    @club = club
    @player = PlayerDecorator.new(player)
    @type = type
    @ajax = ajax
  end

  def select_categories(field=nil)
    query = 'tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND
             ? >= categories.age_min AND ? < categories.age_max AND category_rankings.ranking_id = ?'
    tournaments = @tournament.includes(:category).joins(category: :category_rankings)
                              .where(query,  @club, @player.gender, @type, @player.age, @player.age, @player.ranking_histories.max_by{|ranking| ranking.start_date}.ranking.id)
    if @ajax
      tournaments.map{ |tournament| generate_option_tag(tournament, field) }.uniq.sort_by {|category| category.scan(/'(\d+)'/)[0][0].to_i}
    else
      tournaments.map{ |tournament| [tournament.category.category, tournament.category.id]}.uniq.sort {|a,b| a[1] <=> b[1]}
    end
  end
  
  def select_dates(category, field=nil)
    query = 'tournaments.club_id = ? AND categories.gender = ? AND categories.c_type = ? AND
             ? >= categories.age_min AND ? < categories.age_max AND tournaments.category_id = ?'
    tournaments = @tournament.includes(:category).joins(:category)
                    .where(query, @club, @player.gender, @type, @player.age, @player.age, category)
    
    if @ajax
      tournaments.map{ |tournament| generate_option_tag(tournament, field) }.uniq.sort_by {|category| category.scan(/'(\d+)'/)[0][0].to_i}
    else
      tournaments.map{ |tournament| ["#{tournament.start_date.strftime('%d/%m/%Y')} - #{tournament.end_date.strftime('%d/%m/%Y')}", tournament.id]}
                 .uniq.sort {|a,b| a[1] <=> b[1]}
    end
  end

  private

  def generate_option_tag(tournament, type)
    if type == 'club'
      "<option value='#{tournament.category.id}'>#{tournament.category.category}</option>"
    elsif type == 'category'
      "<option value='#{tournament.id}'>#{tournament.start_date.strftime("%d/%m/%Y")} - #{tournament.end_date.strftime("%d/%m/%Y")}</option>"
    end
  end

end