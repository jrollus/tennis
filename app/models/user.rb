class User < ApplicationRecord
  # Concerns
  include NestedUserConcern
  
  # Devise
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  # Active Storage
  has_one_attached :avatar

  # Relations
  has_one :player
  has_many :ranking_histories, through: :player
  has_many :clubs
  
  # Nested Attributes
  accepts_nested_attributes_for :player

end
