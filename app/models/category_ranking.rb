class CategoryRanking < ApplicationRecord
    # Relations
    belongs_to :category
    belongs_to :ranking
end