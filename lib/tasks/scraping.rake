namespace :scraping do
  TOURNAMENT_GENERAL_URL = "https://www.aftnet.be/MyAFT/Tooltip/TournamentDetails/"
  TOURNAMENT_SEARCH_URL = "https://www.aftnet.be/MyAFT/Competitions/Tournaments/"
  TOURNAMENT_CATEGORIES_URL = "https://www.aftnet.be/MyAFT/Tooltip/TournamentCategories/"
  SEARCH_TOURNAMENT_BUTTON_TEXT = "OK"
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"

  desc "Scheduled task to scrape tournament data"
  task tournaments: :environment do

    ### Scrape Data ###

    # Setup WATIR
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--remote-debugging-port=9222')
    browser = Watir::Browser.new :chrome, :options => options

    browser.goto(TOURNAMENT_SEARCH_URL)
    browser.goto(TOURNAMENT_SEARCH_URL)
    browser.button(text: SEARCH_TOURNAMENT_BUTTON_TEXT).fire_event "onclick"

    sleep 3
    parser_all_tournaments = Nokogiri::HTML(browser.html)

    # For each tournament
    tournaments_data = []
    tournament_index = 1
    nbr_tournaments = parser_all_tournaments.search('.grid-data-item').count

    parser_all_tournaments.search('.grid-data-item').each do |tournament|
      unless tournament.search('.register-closed').empty?
        tournament_id = tournament.search('dd').search('a').first["data-url"].split("/")[-1]

        # Log Scraping Info
        puts "Attempting to scrape: #{tournament_id.to_i}"

        # Get general tournament data
        browser.goto(TOURNAMENT_GENERAL_URL + tournament_id)
        parser_tournament = Nokogiri::HTML(browser.html)
        
        club_name = parser_tournament.search('div')[0].search('div')[1].inner_text.strip.scan(/^Club:\s{1}(.+)$/)[0][0].capitalize
        start_date = parser_tournament.search('div')[0].search('div')[2].inner_text.strip.scan(/^Date: Du (.+) au (.*)$/)[0][0]
        end_date = parser_tournament.search('div')[0].search('div')[2].inner_text.strip.scan(/^Date: Du (.+) au (.*)$/)[0][1]

        # Get specific tournament data
        browser.goto(TOURNAMENT_CATEGORIES_URL + tournament_id)
        parser_tournament = Nokogiri::HTML(browser.html)
        parser_tournament.search('.grid-data-item').each do |category|
          tournaments_data << {
            tournament_id: tournament_id.to_i,
            club_name: club_name,
            start_date: start_date,
            end_date: end_date, 
            category: category.search('dd')[0].inner_text.strip,
            nbr_registered: category.search('dd')[3].inner_text.include?("inscrit") ? category.search('dd')[3].inner_text.strip.scan(/^(\d+)\s.+$/)[0][0].to_i : category.search('dd')[2].inner_text.strip.scan(/^(\d+)\s.+$/)[0][0].to_i
          }
        end

        # Log Scraping Info
        puts "Tournament ID: #{tournament_id}"
        puts "Total Tournaments Scraped: #{tournament_index} / #{nbr_tournaments}"
        puts "------------------------------------------"

        tournament_index += 1
      end
    end

    ### Update DB ###
    clubs = Club.all
    categories = Category.all
    nbr_tournaments_added = 0
    tournaments_data.each do |tournament_data|
      tournament = Tournament.new()
      club = clubs.find{|club| club.name.downcase == tournament_data[:club_name].downcase}
      category = categories.find{|category| category.category.downcase == tournament_data[:category].downcase}
      if club && category
        tournament.club_id = club.id
        tournament.category_id = category.id
        tournament.start_date = tournament_data[:start_date]
        tournament.end_date = tournament_data[:end_date]
        tournament.nbr_participants = tournament_data[:nbr_registered]
        tournament.validated = true
        if tournament.save
          nbr_tournaments_added += 1
        end
      end
    end
    puts "#{nbr_tournaments_added} / #{tournaments_data.size} added"
  end 
end
