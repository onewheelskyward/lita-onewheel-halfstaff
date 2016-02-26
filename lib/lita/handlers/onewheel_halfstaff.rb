require 'nokogiri'

module Lita
  module Handlers
    class OnewheelHalfstaff < Handler
      route /^halfstaff$/,
            :get_flag_status,
            command: true

      def get_flag_status(response)
        get_flag_data
      end

      def get_flag_data
        flag_html = RestClient.get 'http://www.flagsexpress.com/HalfStaff_s/1852.htm'
        noko_flag = Nokogiri::HTML flag_html
        noko_flag.css('a').each do |a_tag|
          if a_tag['href'].match /http\:\/\/www\.flagsexpress\.com\/Articles\.asp\?ID\=/i
            goober = parse_flag_status_text(a_tag.text)
            # puts goober[:date]
            # puts goober[:place]
            # puts goober[:desc]
          end
        end
      end

      def parse_flag_status_text(text)
        pieces = text.split(/ - /)
        if pieces[0].match(/ 2016/)
          # puts pieces.inspect
          if date_matches = pieces[0].match(/(\w+\s+\d+,\s+\d+)/)
            puts 'Standard'
            puts date_matches[1]
          elsif date_matches = pieces[0].match(/(\w+)\s+(\d+)-(\d+)/)
            puts 'Date range'
            puts date_matches[1]
            puts date_matches[2]
            puts date_matches[3]
          elsif date_matches = pieces[0].match(/(\w+\s+\d+) until sunset \w+, (\w+\s+\d+)/)
            puts 'until sunset'
            puts date_matches[1]
            puts date_matches[2]
          else
            puts "Couldn't match #{pieces[0]}"
          end

          # puts date_matches.inspect
        end

        # return matches[1], matches[2], matches[3]
      end

      Lita.register_handler(self)
    end
  end
end
