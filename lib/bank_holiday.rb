require 'httparty'
require 'uri'
require 'icalendar'
require 'date'

module BankHoliday
  
  # Get a list of all bank holidays
  def self.all
    Rails.cache.fetch('bank_holidays', expires_in: 2.weeks) do
      get_dates
    end
  end

  def self.today?
    today = DateTime.now.in_time_zone('London')
    d, m, y = today.day, today.month, today.year
    Rails.cache.fetch("bank_holiday_#{y}_#{m}_#{d}", expires_in: 2.weeks) do
      result = false
      all.each do |entry|
        if entry[:date].year == y && entry[:date].month == m && entry[:date].day == d
          result = true
          break
        end
      end
      result
    end
  end
  
  private
  
    def self.get_dates
      ics = Icalendar.parse(HTTParty.get "https://www.gov.uk/bank-holidays/england-and-wales.ics")
      cal = ics.first
      cal.events.collect do |e|
        {:date => e.dtstart, :name => e.summary}
      end
    end
    
end