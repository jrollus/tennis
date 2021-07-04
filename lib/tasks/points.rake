namespace :points do
  desc "Task to compute the legacy points for the season 2020"
  task compute_legacy: :environment do
    Player.all.each do |player|
      PointsJob.perform_later(player, Date.parse('30-12-2020'))
    end
  end

  desc "Task to compute the points for the current season"
  task compute_current_season: :environment do
    Player.all.each do |player|
      PointsJob.perform_later(player, Date.today)
    end
  end

  desc "Task to compute the points for the active players for the current season"
  task compute_active_current_season: :environment do
    current_season = YearDatesService.get_year_nbr_dates
    Player.joins(game_players: :game).where('games.date BETWEEN ? AND ?', current_season[:start_date], current_season[:end_date]).each do |player|
      PointsJob.perform_later(player, Date.today)
    end
  end
end
