require 'nokogiri'
require 'restclient'

module Lita
  module Handlers
    class OnewheelHalfstaff < Handler
      route /^half(staff|mast)$/,
            :get_flag_status,
            command: true,
            help: {'halfstaff' => 'Get any current half staff information from flagsexpress.com.'}

      route /^half(staff|mast) history$/,
            :get_history,
            command: true,
            help: {'halfstaff history' => 'Get the wikipedia history of lowering the flag to half staff(mast).'}

      def get_flag_status(response)
        flag_data = get_flag_data
        if flag_data.empty?
          Lita.logger.info 'No flag match for today.'
          response.reply ["Everything's cool, yo.", 'No half staff known.'].sample
        else
          Lita.logger.info 'Got a match on the flag.'
          flag_data.each do |reply|
            response.reply reply
          end
        end
      end

      def get_flag_data
        flag_html = RestClient.get 'http://www.flagsexpress.com/HalfStaff_s/1852.htm'
        results = []
        noko_flag = Nokogiri::HTML flag_html
        noko_flag.css('a').each do |a_tag|
          if a_tag['href'].match /http\:\/\/www\.flagsexpress\.com\/Articles\.asp\?ID\=/i
            if is_at_half_staff(a_tag.text)
              pieces = a_tag.text.split(/ - /)
              Lita.logger.info 'Returning flag data'
              results.push "#{pieces[1]} - #{pieces[2]} - #{a_tag['href']}"
            end
          end
        end
        results
      end

      def is_at_half_staff(text)
        half_staff = false
        pieces = text.split(/ - /)
        current_year = Date::today.year
        if pieces[0].match(/#{current_year}/)
          Lita.logger.info "Checking for flag date match on #{text}"
          if date_matches = pieces[0].match(/(\w+\s+\d+,\s+\d+)/)   # February 26, 2016
            # Lita.logger.info 'Standard'
            # Lita.logger.info date_matches[1]
            date = Date::parse(date_matches[1])
            half_staff = date == Date::today
          elsif date_matches = pieces[0].match(/(\w+)\s+(\d+)-(\d+)/)   # March 5-11, 2016
            # Lita.logger.info 'Date range'
            month = date_matches[1]
            day_start = date_matches[2]
            day_end = date_matches[3]
            half_staff = does_today_match_date_range(month, day_start, month, day_end, current_year)
          elsif date_matches = pieces[0].match(/(\w+)\s+(\d+) until sunset \w+, (\w+)\s+(\d+)/i)   # May 3 until sunset Sunday, December 12
            # Lita.logger.info 'until sunset'
            start_month = date_matches[1]
            start_day = date_matches[2]
            end_month = date_matches[3]
            end_day = date_matches[4]
            half_staff = does_today_match_date_range(start_month, start_day, end_month, end_day, current_year)
          elsif date_matches = pieces[0].match(/(\w+)\s+(\d+) until the (\d+)\w+, (\d+)/i)   # March 7 until the 11th, 2016
            # Lita.logger.info 'until sunset'
            start_month = date_matches[1]
            start_day = date_matches[2]
            end_day = date_matches[3]
            half_staff = does_today_match_date_range(start_month, start_day, start_month, end_day, current_year)
          else
            Lita.logger.info "Couldn't match #{pieces[0]}"
          end
        end

        half_staff
      end

      def does_today_match_date_range(start_month, start_day, end_month, end_day, current_year)
        start_time = DateTime::parse("#{start_month} #{start_day} #{current_year} 00:00")
        end_time = DateTime::parse("#{end_month} #{end_day} #{current_year} 23:59:59")
        return (start_time..end_time).cover? DateTime.now
      end

      def get_history(response)
        response.reply 'https://en.wikipedia.org/wiki/Half-mast'
      end

      Lita.register_handler(self)
    end
  end
end
