class TournamentDecorator < SimpleDelegator
  def model
    __getobj__
  end

  def tournament_date
    "#{self.start_date.strftime("%d/%m/%Y")} - #{self.end_date.strftime("%d/%m/%Y")}"
  end
end