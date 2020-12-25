json.array! @players do |player|
    json.extract! player, :id, :first_name, :last_name, :affiliation_number
    begin
        json.ranking player.ranking_histories.last.ranking.name
    rescue
        json.ranking ""
    end
end