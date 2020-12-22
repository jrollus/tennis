class GamesController < ApplicationController
  before_action :set_clubs_courts, only: [ :new, :edit ]

  def index
  end

  def show
  end

  def new
    @form = GameForm.new
    authorize @form
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_clubs_courts
    player_age = Date.today.year - current_user.player.birthdate.year
    query = "categories.gender = ? AND categories.c_type = 'single' AND ? >= categories.age_min AND ? < categories.age_max "
    @clubs = Club.joins(tournaments: :category).where(query, current_user.player.gender, player_age, player_age).uniq.sort
    @courts = Court.distinct.pluck(:court_type).sort.map{|court| court.titleize}
  end

end
