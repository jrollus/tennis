class CourtType < ApplicationRecord
    # Relations
    has_many :courts
    has_many :games
end