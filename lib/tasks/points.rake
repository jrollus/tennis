namespace :points do
  desc "TODO"
  task compute_legacy: :environment do
    Player.all.each do |player|
      PointsJob.perform_now(player, Date.parse('30-12-2020'))
    end
  end

end
