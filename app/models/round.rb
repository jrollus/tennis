class Round < ApplicationRecord
    # Relations
    has_many :category_rounds
    has_many :games
end