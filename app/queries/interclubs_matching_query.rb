class InterclubsMatchingQuery
    def initialize(player)
      @player = player
    end
  
    def get_interclubs_matching
      query = 'divisions.gender = ? AND ? >= divisions.age_min AND ? < divisions.age_max'
      interclubs = Interclub.includes(:division).joins(:division).where(query, @player.gender,@player.age, @player.age)
      interclubs.map do |interclub|
        [interclub.division.name, interclub.id]
      end
    end
  end