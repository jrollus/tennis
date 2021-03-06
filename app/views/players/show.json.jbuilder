json.extract! @player, :first_name, :last_name, :gender, :birthdate, :affiliation_number
begin
  json.extract! @player.ranking_histories.max_by{|ranking| ranking.start_date}, :year, :ranking_id
rescue
  json.year  Date.today.year
  json.ranking_id ''
end
json.extract! @player.club, :id
