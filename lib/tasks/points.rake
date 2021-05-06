namespace :points do
  desc "Task to compute the legacy points for the season 2020"
  task compute_legacy: :environment do
    Player.all.each do |player|
      PointsJob.perform_now(player, Date.parse('30-12-2020'))
    end
  end
end
