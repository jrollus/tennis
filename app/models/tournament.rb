class Tournament < ApplicationRecord
  belongs_to :club
  belongs_to :category

  private

  def name
    "#{club.name} - #{start_date} - #{end_date} - #{category.category}"
  end

  def tournament_date
    "#{start_date} - #{end_date}"
  end
end
