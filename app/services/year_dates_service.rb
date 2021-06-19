class YearDatesService 
  def self.get_year_nbr_dates(date=Date.today)
    case ENV['RANKINGS_PER_YEAR'].to_i
    when 1
      year_number = 1
      if date.month <= 10
        start_date = Date.new(date.year - 1, 11, 1)
        end_date = Date.new(date.year, 10, -1)
      else
        start_date = Date.new(date.year, 11, 1)
        end_date = Date.new(date.year + 1, 10, -1)
      end
    when 2
      if date.month > 10 || date.month < 6
        year_number = 1
        if date.month > 10
          start_date = Date.new(date.year, 11, 1)
          end_date =  Date.new(date.year + 1, 5, -1)
        else
          start_date = Date.new(date.year - 1, 11, 1)
          end_date =  Date.new(date.year, 5, -1)
        end
      else
        year_number = 2
        start_date = Date.new(date.year, 6, 1)
        end_date =  Date.new(date.year, 10, -1)
      end
    end
    
    return {
      year_number: year_number,
      start_date: start_date,
      end_date: end_date
    }
  end
end


  