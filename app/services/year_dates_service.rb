class YearDatesService
  RANKINGS_PER_YEAR = 1
  
  def self.get_year_nbr_dates(date=Date.today)
    case RANKINGS_PER_YEAR
    when 1
      year_number = 1
      start_date = Date.new(date.year, 1, 1)
      end_date = Date.new(date.year, 12, -1)
    when 2
      year_number = (date.month / 6.0).ceil
      start_date = Date.new(date.year, year_number + (5 * (year_number - 1)), 1) 
      end_date = Date.new(date.year, 6 * year_number, -1)
    when 4
      year_number = (date.month / 3.0).ceil
      start_date = Date.new(date.year, year_number + (2 * (year_number - 1)), 1) 
      end_date = Date.new(date.year, 3 * year_number, -1)
    end
    
    return {
      year_number: year_number,
      start_date: start_date,
      end_date: end_date
    }
  end
end


  