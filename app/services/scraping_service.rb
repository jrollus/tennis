class ScrapingService

  # CLUB

  def self.get_courts(club_elements)
    club_courts = []
    (club_elements.size - NBR_BASE_CLUB_INFO...club_elements.size).each do |index|
      # Indoor / Outdoor
      if club_elements[index].inner_text.include?(INDOOR_TEXT)
        is_indoor = true
        courts = club_elements[index].inner_text.strip.gsub(INDOOR_TEXT+":","").split(",")
      else
        courts = club_elements[index].inner_text.strip.gsub(OUTDOOR_TEXT+":","").split(",")
        is_indoor = false
      end 
  
      # For each court, extract relevant data
      courts.each do |court|
        nbr_courts = court.gsub(/^\d+/, '').strip.to_i
        (nbr_courts).times do
          club_courts << {
            indoor: is_indoor,
            type: court.strip.scan(/^(\d+)(.*?)((\(|[-]).*)?$/)[0][1].strip,
            light: (court.include?(LIGHT_ON_TEXT) || is_indoor) ? true : false
          }
        end
      end
    end
    return club_courts
  end  

  def self.get_club_details(parser_club)
    club_details = {}
    club_details[:address] = parser_club.search('#colInfo dl dd')[0].inner_text.strip

    parser_club.search('#colInfo dl dd').each do |info_row|
      # Phone number
      if !info_row.inner_text.match?(/[A-Za-z]/)
        club_details[:phone_number] = info_row.inner_text.gsub(/\W/,"").strip
      # Email
      elsif info_row.inner_text.include?("@")
        club_details[:email] = info_row.inner_text
      # Website
      elsif info_row.inner_text.include?("www") || info_row.inner_text.include?("http")
        club_details[:website] = info_row.inner_text
      end
    end

    return club_details
  end

  def self.get_players_basic_info(parser_club)
    players = []
    parser_club.search('.grid-data-item.profile').each do |player|
      regex_parse = player.search('dd')[0].inner_text.strip.reverse.scan(/^\)(\d+)\(\s(.+)\s(.+)$/)
      players << {
        affiliation_nbr: regex_parse[0][0].reverse,
        first_name:  regex_parse[0][1].reverse.strip.capitalize,
        last_name: regex_parse[0][2].reverse.capitalize,
        ranking: player.search('dd')[1].inner_text.strip.scan(/^(A Nat|A int|.{1,6})(\s*)(.*)$/)[0][0],
        national_ranking: player.search('dd')[1].inner_text.strip.scan(/^(A Nat|A int|.{1,6})(\s*)(.*)$/)[0][2]
      }
      # Debug Info
      #puts "Scraping player: #{players.size} / #{parser_club.search('.grid-data-item.profile').count}"
    end
    return players
  end

  # PLAYER

  def self.clean_result(raw_result, invert_result)
    result = {}
  
    result_by_sets = raw_result.split("-")

    result["status"] = "completed"
    result_by_sets.each do |set|
      if set.include?("Ab.")
        result["status"] = "retirement"
      elsif set.include?("Bless.")
        result["status"] = "injury"
      elsif set.include?("WO")
        result["status"] = "WO"
      end
    end

    result_by_sets.each_with_index do |set, index|
      set_split = set.split("/")
      # Manage the case of WO, retirement or injury
      set_split[-1] = set_split[-1][0]
      if (set_split[0] != "0") || (set_split[1] != "0")
        result["set_#{index+1}"] = invert_result ? "#{set_split[1]}/#{set_split[0]}" : set
      end
    end

    return result
  end

  def self.get_game_round(browser, url_scan, tournament_id, category_id)
    type_of_draw = url_scan[0][0]
    if type_of_draw == "F"
      game_round = url_scan[0][1] == "1" ? "final" : "1_" + (2**(url_scan[0][1].to_i - 1)).to_s
    elsif type_of_draw == "Q"
      if url_scan[0][1] == "3"
        game_round = "1_8"
      elsif url_scan[0][1] == "4"
        game_round = "1_16"
      elsif url_scan[0][1] == "5"
        game_round = "1_32"
      end
    elsif type_of_draw == "P"
      sleep 0.5
      browser.goto(TOURNAMENT_DRAW_URL.gsub("XXXX", tournament_id.to_s).gsub("YYYY", category_id.to_s))
      parser_round = Nokogiri::HTML(browser.html)
      nbr_qualifications = parser_round.search('.g_round_label').count.zero? ? 1 : 2
      game_round = "1_" + (2**(url_scan[0][1].to_i + nbr_qualifications)).to_s
    elsif type_of_draw.match?(/^S\w{1}$/)
      game_round = "poule"
    elsif type_of_draw == "S"
      game_round = url_scan[0][1] == "1" ? "final" : "1_" + (2**(url_scan[0][1].to_i - 1)).to_s
    end
    return game_round
  end

  def self.get_player_results(browser, parser_player, affiliation_number)
    player_results = []
    parser_player.search('#divPlayerDetailTournamentSingleResultData dl').each do |game|
      
      victory =  game.search('dd img').first["src"].include?("defeat") ? false : true
    
      if game.search('dd')[0].inner_text.strip.match?(/\d{2}\/\d{2}\/\d{4}/)
        date = game.search('dd')[0].inner_text.strip.scan(/^(.+)(\d{2}\/\d{2}\/\d{4})$/)[0][1]
        club = game.search('dd')[0].inner_text.strip.scan(/^(.+)(\d{2}\/\d{2}\/\d{4})$/)[0][0].strip.capitalize
      else
        date = ""
        club = game.search('dd')[0].inner_text.strip.capitalize
      end
      
      tournament_id = game.search('.view-draw')[0]["data-url"].scan(/^.+idTournoi=(\w+)&.+$/)[0][0].to_i
      category_id =  game.search('.view-draw')[0]["data-url"].scan(/^.+idCategory=(\w+)&.+$/)[0][0].to_i
      game_round = get_game_round(browser, game.search('.view-draw')[0]["data-url"].scan(/^.+drawType=(\w+)&roundIndex=(\d+).+$/), tournament_id, category_id)
      
      player_results << {
                          date: date,
                          tournament_id: tournament_id,
                          tournament_club: club,
                          tournament_category: game.search('dd')[1].inner_text.strip,
                          victory: victory,
                          opponent: game.search('dd a')[2]["data-url"].scan(/\/MyAFT\/Players\/Detail\/(\d+)/)[0][0],
                          score: clean_result(game.search('dd')[3].inner_text.strip, !victory),
                          round: game_round
                        }
    end
    return player_results
  end
  
end