class Interclub < ApplicationRecord
  # Relations
  belongs_to :division
  has_many :games
end
  