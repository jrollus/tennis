class Category < ApplicationRecord
    # Relations
    has_many :tournaments
    has_many :category_rankings
    has_many :rankings, through: :category_rankings
    has_many :category_rounds
end
