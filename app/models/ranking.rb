class Ranking < ApplicationRecord
    # Relations
    has_many :ranking_histories
    has_many :category_rankings
end
