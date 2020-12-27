class Court < ApplicationRecord
  # Relations
  belongs_to :club
  belongs_to :court_type
end
