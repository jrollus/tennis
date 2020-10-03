class RankingHistory < ApplicationRecord
  belongs_to :ranking
  belongs_to :player
end
