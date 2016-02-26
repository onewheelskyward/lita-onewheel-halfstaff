require 'nokogiri'

module Lita
  module Handlers
    class OnewheelHalfstaff < Handler
      route /^halfstaff$/,
            :get_flag_status,
            command: true

      def get_flag_status(response)
        if flag_array = get_flag_data
          reply = flag_array
        else
          reply = ["Everything's cool, yo."].sample
        end

        response.reply reply
      end

      def get_flag_data
        flag_html = RestClient.get 'http://www.flagsexpress.com/HalfStaff_s/1852.htm'
        noko_flag = Nokogiri::HTML flag_html
        noko_flag.css('a').each do |a_tag|
          if a_tag['href'].match /http\:\/\/www\.flagsexpress\.com\/Articles\.asp\?ID\=/i
            if is_at_half_staff(a_tag.text)
              pieces = a_tag.text.split(/ - /)
              "#{pieces[1]} - #{pieces[2]} - #{a_tag['href']}"
            end
          end
        end
      end

      def is_at_half_staff(text)
        half_staff = false
        pieces = text.split(/ - /)
        current_year = Date::today.year
        if pieces[0].match(/#{current_year}/)
          if date_matches = pieces[0].match(/(\w+\s+\d+,\s+\d+)/)   # February 26, 2016
            # puts 'Standard'
            # puts date_matches[1]
            date = Date::parse(date_matches[1])
            half_staff = date == Date::today
          elsif date_matches = pieces[0].match(/(\w+)\s+(\d+)-(\d+)/)   # March 5-11, 2016
            # puts 'Date range'
            month = date_matches[1]
            day_start = date_matches[2]
            day_end = date_matches[3]
            half_staff = does_today_match_date_range(month, day_start, month, day_end, current_year)
          elsif date_matches = pieces[0].match(/(\w+)\s+(\d+) until sunset \w+, (\w+)\s+(\d+)/i)   # May 3 until sunset Sunday, December 12
            # puts 'until sunset'
            start_month = date_matches[1]
            start_day = date_matches[2]
            end_month = date_matches[3]
            end_day = date_matches[4]
            half_staff = does_today_match_date_range(start_month, start_day, end_month, end_day, current_year)
          else
            puts "Couldn't match #{pieces[0]}"
          end
        end

        half_staff
      end

      def does_today_match_date_range(month_start, day_start, month_end, day_end, current_year)
        start_time = DateTime::parse("#{month_start} #{day_start} #{current_year} 00:00")
        end_time = DateTime::parse("#{month_end} #{day_end} #{current_year} 23:59")
        return (start_time..end_time).include? Time.now
      end

      Lita.register_handler(self)
    end
  end
end
