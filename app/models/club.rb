class Club < ApplicationRecord
    # Relations
    has_many :courts
    has_many :tournaments
    has_many :categories, through: :tournaments
    has_many :players
end
