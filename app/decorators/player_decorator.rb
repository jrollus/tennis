class PlayerDecorator < SimpleDelegator
  def model
    __getobj__
  end

  def age
    Date.today.year - self.birthdate.year
  end

  def full_name
    "#{self.first_name.capitalize} #{self.last_name.capitalize}"
  end

  def player_description
    "#{self.first_name.capitalize} #{self.last_name.capitalize} (#{self.affiliation_number}) #{self.ranking_histories.last.ranking.name ? self.ranking_histories.last.ranking.name : ''}"
  end
end