namespace :scraping do
  require "open-uri"
  require "nokogiri"
  require "selenium-webdriver"
  require "json"
  require "csv"
  require "watir"
  require "byebug"

  BASE_URL = "https://www.aftnet.be"
  CLUB_SEARCH_URL = "https://www.aftnet.be/MyAFT/Clubs/Search"
  PLAYER_DETAILS_URL = "https://www.aftnet.be/MyAFT/Players/Detail/"
  PLAYER_RESULTS = "https://www.aftnet.be/MyAFT/Players/VictoryDefeat?numFed=XXXX&singleValue=5"
  TOURNAMENT_GENERAL_URL = "https://www.aftnet.be/MyAFT/Tooltip/TournamentDetails/"
  TOURNAMENT_CATEGORIES_URL = "https://www.aftnet.be/MyAFT/Tooltip/TournamentCategories/"
  TOURNAMENT_DRAW_URL = "https://www.aftnet.be/MyAFT/Competitions/TournamentDraw?idTournoi=XXXX&idCategory=YYYY&drawType=Q&roundIndex=5&rowIndex=1"
  LOCAL_URL = "./aft.html"
  FILE_OUTPUT_PATH = "./clubs.json"
  FILE_RESULTS_PATH = "./results.json"
  FILE_TOURNAMENTS_PATH  = "./tournaments.json"
  FILE_FLEMISH_PLAYERS = "./flemish_players.csv"

  NBR_BASE_CLUB_INFO = 2
  SAVE_RESULTS_FREQ = 100
  INDOOR_TEXT = "Intérieur"
  OUTDOOR_TEXT = "Extérieur"
  LIGHT_ON_TEXT = "éclairé"
  SEACH_BUTTON_TEXT = "Appliquer"
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"

  desc "TODO"
  task aft_scrape_club_data: :environment do
    clubs = []
    total_players = 0

    # Setup WATIR
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    browser = Watir::Browser.new :chrome, :options => options
    browser.goto(CLUB_SEARCH_URL)
    browser.checkbox(id: "CourtOutdoor").fire_event "click" 
    browser.button(text: SEACH_BUTTON_TEXT).fire_event "onclick"

    # If club search works then scrape online
    begin
      browser.dl(:class => "club-item").wait_until(&:present?)
      parser_all_clubs = Nokogiri::HTML(browser.html)
    # Otherwise save POST response in local HTML file and parse it
    rescue Watir::Wait::TimeoutError => e
      html_content = open(LOCAL_URL).read
      parser_all_clubs = Nokogiri::HTML(html_content)
    end

    # For each club
    parser_all_clubs.search('.club-item').each do |club|
      # Log Scraping Info
      club_name = club.search('dd')[0].inner_text.strip.scan(/^(.+)\s\((\d+)\)$/)[0][0]
      puts "Attempting to scrape: #{club_name}"

      courts = ScrapingService.get_courts(club.search('dd'))
      club_url = BASE_URL + club.search('a').first["data-url"]

      # Extract further details from the specific club page
      browser.goto(club_url)

      # Wait until AJAX request generates the player list
      # If it times out, assume there are no players in the club
      has_players = true
      begin
        browser.dl(:class => "profile").wait_until(&:present?)
      rescue Watir::Wait::TimeoutError => e
        has_players = false
      end

      parser_club = Nokogiri::HTML(browser.html)
      club_details = ScrapingService.get_club_details(parser_club)

      # Extract players info
      players = has_players ? ScrapingService.get_players_basic_info(parser_club) : []
      
      clubs << {
        url: club_url,
        club_name: club_name.capitalize,
        club_code: club.search('dd')[0].inner_text.strip.scan(/^(.+)\s\((\d+)\)$/)[0][1].to_i,
        club_zip_code: club.search('dd')[1] ? club.search('dd')[1].inner_text.strip.gsub(/[^\d]/, '').to_i : "",
        club_address: club_details[:address],
        club_phone_number: club_details[:phone_number],
        club_email: club_details[:email],
        club_website: club_details[:website],
        club_city: club.search('dd')[1] ? club.search('dd')[1].inner_text.strip.gsub(/[^[a-zA-Z\s]]/, '').strip.capitalize : "",
        club_courts: courts,
        club_players: players
      }

      total_players += players.size

      # Log Scraping Info
      puts "Club Name: #{clubs[-1][:club_name]}"
      puts "Club Players : #{players.size}"
      puts "Total Clubs Scraped :  #{clubs.size} / #{parser_all_clubs.search('.club-item').count}"
      puts "Total Players Scraped: #{total_players}"
      puts "------------------------------------------"

      # Sleep in case of limited number of requests
      sleep 2
    end

    # JSON ouput
    # File.open(FILE_OUTPUT_PATH,"w") do |f|
    #   f.write(clubs.to_json)
    # end
  end

  desc "TODO"
  task aft_scrape_tournament_data: :environment do
    # Read JSON results data
    players_results = JSON.parse(File.read(FILE_RESULTS_PATH))

    # Extract all tournaments IDs
    tournaments_id = []
    players_results.each do |player|
      if player["results"]
        player["results"].each do |result|
          tournaments_id << result["tournament_id"]
        end
      end
    end

    # Setup WATIR
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    browser = Watir::Browser.new :chrome, :options => options

    # For each tournament, extract categories, dates and number of registered players
    tournaments_data = []
    tournament_index = 1
    tournaments_id.uniq!.each do |tournament|
      # Log Scraping Info
      puts "Attempting to scrape: #{tournament}"

      # Get general tournament data
      browser.goto(TOURNAMENT_GENERAL_URL + tournament.to_s)
      parser_tournament = Nokogiri::HTML(browser.html)
      
      club_name = parser_tournament.search('div')[0].search('div')[1].inner_text.strip.scan(/^Club:\s{1}(.+)$/)[0][0].capitalize
      start_date = parser_tournament.search('div')[0].search('div')[2].inner_text.strip.scan(/^Date: Du (.+) au (.*)$/)[0][0]
      end_date = parser_tournament.search('div')[0].search('div')[2].inner_text.strip.scan(/^Date: Du (.+) au (.*)$/)[0][1]

      # Get specific tournament data
      browser.goto(TOURNAMENT_CATEGORIES_URL + tournament.to_s)
      parser_tournament = Nokogiri::HTML(browser.html)
      parser_tournament.search('.grid-data-item').each do |category|
        tournaments_data << {
          tournament_id: tournament.to_i,
          club_name: club_name,
          start_date: start_date,
          end_date: end_date, 
          category: category.search('dd')[0].inner_text.strip,
          nbr_registered: category.search('dd')[3].inner_text.include?("inscrit") ? category.search('dd')[3].inner_text.strip.scan(/^(\d+)\s.+$/)[0][0].to_i : category.search('dd')[2].inner_text.strip.scan(/^(\d+)\s.+$/)[0][0].to_i
        }
      end

      # Log Scraping Info
      puts "Tournament ID: #{tournament}"
      puts "Total Tournaments Scraped: #{tournament_index} / #{tournaments_id.size}"
      puts "------------------------------------------"

      tournament_index += 1
    end

    File.open(FILE_TOURNAMENTS_PATH,"w") do |f|
      f.write(tournaments_data.to_json)
    end
  end

  desc "TODO"
  task aft_scrape_players_results: :environment do
    # Read JSON results data
    players_results = JSON.parse(File.read(FILE_RESULTS_PATH))
  
    # Setup WATIR
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    browser = Watir::Browser.new :chrome, :options => options

    # For each player, retrieve extra data
    player_index = 1
    players_results.map! do |player|
      # If player hasn't been scraped
      if player["scraped"].nil?
        # Log Scraping Info
        puts "Attempting to scrape: #{player["affiliation_nbr"]}"
        # In case there is a failure on the AFT server-side, wait 60 seconds and resume the scraping
        begin
          sleep 0.5 # To avoid server rejecting requests
          browser.goto(PLAYER_DETAILS_URL + player["affiliation_nbr"].to_s)
          
          parser_player = Nokogiri::HTML(browser.html)
          player["gender"] = parser_player.search('#colInfo dd img').first["src"].include?("female") ? "female" : "male"
          
          if parser_player.search('#divPlayerDetailTournamentSingleResultData dl').count !=0
            player["results"] = ScrapingService.get_player_results(browser, parser_player, player["affiliation_nbr"].to_s)
          end

          player["scraped"] = true

          save_results(players_results) if (player_index % SAVE_RESULTS_FREQ).zero?

          # Log Scraping Info
          puts "Player affiliation number: #{player["affiliation_nbr"]}"
          puts "Total Players Scraped: #{player_index} / #{players_results.size}"
          puts "------------------------------------------"
        rescue
          # Log Scraping Info
          puts "Server issue, saving results and rebooting code in 30 seconds"
          save_results(players_results)
          sleep 30
          Rake::Task["scraping:aft_scrape_players_results"].reenable
          Rake::Task["scraping:aft_scrape_players_results"].invoke
        end
      end

      player_index += 1
      
      player
    end
  end

  
end
