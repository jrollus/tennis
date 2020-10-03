class Club < ApplicationRecord
    has_many :courts
    has_many :tournaments
    has_many :players
end
