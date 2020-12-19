if @player
    json.extract! @player, :first_name, :last_name, :gender, :birthdate, :affiliation_number
    json.extract! @player.ranking_histories.last, :year, :ranking_id
    json.extract! @player.club, :id
end