class PlayerDecorator < SimpleDelegator
  def model
    __getobj__
  end

  def age
    Date.today.year - self.birthdate.year
  end

  def full_name
    "#{self.first_name.titleize} #{self.last_name.titleize}"
  end

  def player_description
    ranking = self.ranking_histories.max_by{|ranking| ranking.start_date}.ranking.name
    "#{self.first_name.titleize} #{self.last_name.titleize} (#{self.affiliation_number}) #{ranking ? ranking : ''}"
  end
end