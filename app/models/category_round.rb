class CategoryRound < ApplicationRecord
    # Relations
    belongs_to :category
    belongs_to :round
end