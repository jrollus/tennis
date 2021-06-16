namespace :scraping do
  TOURNAMENT_GENERAL_URL = "https://www.aftnet.be/MyAFT/Tooltip/TournamentDetails/"
  TOURNAMENT_SEARCH_URL = "https://www.aftnet.be/MyAFT/Competitions/Tournaments/"
  TOURNAMENT_CATEGORIES_URL = "https://www.aftnet.be/MyAFT/Tooltip/TournamentCategories/"
  PLAYER_DETAILS_URL = "https://www.aftnet.be/MyAFT/Players/Detail/"
  REDIRECTION_URL = "https://www.aftnet.be/classements/index.html"
  
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

    # Resize screen to avoid mobile version
    browser.driver.manage.window.maximize
    browser.driver.manage.window.resize_to(1024,900)

    # Reload the page in case it was redirected
    browser.goto(TOURNAMENT_SEARCH_URL)
    browser.goto(TOURNAMENT_SEARCH_URL) if browser.url == REDIRECTION_URL

    # Expand the search form
    begin
      browser.link(:href => '#collapse_competitions_tournament_search_form').wait_until(&:present?).click
    rescue Watir::Wait::TimeoutError => e
      puts "Scraping failed when trying to expand search form"
      return
    end

    # If club search works then scrape online
    begin
      date_start = browser.text_field(:id => "periodStartDate").wait_until(&:present?)
      date_start.set(Date.today.strftime("%d/%m/%Y"))
      browser.button(text: 'OK').fire_event "onclick"
      begin
        browser.div(:id => "tournament_search_results_wrapper").wait_until(&:present?)
        sleep 2
        browser.link(class: 'ui-state-active').click
        parser_all_tournaments = Nokogiri::HTML(browser.html)
      rescue Watir::Wait::TimeoutError => e
        puts "Scraping failed when waiting for the search results"
        return
      end
    # Otherwise scraping failed
    rescue Watir::Wait::TimeoutError => e
      puts "Scraping failed when opening the search form"
      return
    end

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
    total_nbr_tournaments = tournaments_data.size
    failed_insertions = []
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
        else
          total_nbr_tournaments -= 1
        end
      else
        failed_insertions << tournament_data 
      end
    end
    puts "#{nbr_tournaments_added} / #{total_nbr_tournaments} added"

    ## Generate and send .CSV with failed attempts ##
    csv = CSV.generate(headers: true) do |csv|
      csv << failed_insertions.first.keys
      failed_insertions.each do |tournament|
        csv << tournament.values
      end
    end

    ScrapingMailer.tournament_email(nbr_tournaments_added, total_nbr_tournaments, csv).deliver_now
  end

  desc "Task to update all player rankings - pass parameter as rake scraping:update_rankings\[YYYY-MM-DD\]"
  task :update_rankings, [:ranking_date] => [:environment] do |t, args|
    ranking_date = Date.parse(args[:ranking_date])
    
    # Setup WATIR
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--remote-debugging-port=9222')
    browser = Watir::Browser.new :chrome, :options => options

    players = Player.all
    rankings = Ranking.all

    counter = 0
    players.each do |player|
      ranking_history = player.ranking_histories.where('? >= start_date AND ? <= end_date', ranking_date, ranking_date)
      counter += 1
      unless ranking_history.present?
        ### Scrape Data ###
        puts "Scraping #{player.affiliation_number}"
        sleep 0.5 # To avoid server rejecting requests
        browser.goto(PLAYER_DETAILS_URL + player.affiliation_number)
        browser.goto(PLAYER_DETAILS_URL + player.affiliation_number) if browser.url == REDIRECTION_URL
        parser_player = Nokogiri::HTML(browser.html)
        unless parser_player.search('#player-title').empty?
          regex_parse = parser_player.search('#player-title').inner_text.strip.reverse.scan(/^\)(\d+)\(\s(.+)\s(.+)$/)
          player_basic_data = {
            gender: parser_player.search('#colInfo dd img').first["src"].include?("female") ? "female" : "male",
            first_name: regex_parse[0][1].reverse.strip.capitalize,
            last_name: regex_parse[0][2].reverse.capitalize,
            ranking: parser_player.search('#colInfo dd')[2].inner_text.strip.scan(/^(A Nat|A int|.{1,6})(\s*)(.*)$/)[0][0],
            national_ranking: parser_player.search('#colInfo dd')[2].inner_text.strip.scan(/^(A Nat|A int|.{1,6})(\s*)(.*)$/)[0][2]
          }
        end
        puts "Scraping done #{counter} / #{players.size}"

        unless player_basic_data.nil?
          ### Update DB ###
          ranking_period_dates = YearDatesService.get_year_nbr_dates(ranking_date)
          ranking_history = RankingHistory.new()
          ranking_history.player_id = player.id
          ranking_history.year = Date.today.year
          ranking_history.year_number = ranking_period_dates[:year_number]
          ranking_history.start_date = ranking_period_dates[:start_date]
          ranking_history.end_date = ranking_period_dates[:end_date]
          ranking_history.ranking_id = rankings.find{|ranking| (ranking.name == player_basic_data[:ranking] || ranking.name == player_basic_data[:ranking].titleize)}.id
          ranking_history.national_ranking = player_basic_data[:national_ranking]
          ranking_history.validated = true
          ranking_history.save
        end
      end
    end
  end

end
