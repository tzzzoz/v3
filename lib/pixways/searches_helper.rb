module Pixways

  class SearchesHelper

    class << self
      def filter_keywords(keywords)
        keywords.split(/(".*?")/).collect do |subset|
          subset.gsub!('/',' and ')
          if subset[0..0]=='"'
            subset = "\"#{Riddle::Query.escape(subset)}\""
          else
            subset.gsub!(/(\s+|\b)(\?|ou|or)(\s+|\b)/i, ' | ')
            subset.gsub!(/(\s+|\b)(\+|et|and)(\s+|\b)/i, ' & ')
            subset.gsub!(/(\s+|\b)(-|sauf|not)(\s+|\b)/i, ' -')
          end
          subset
        end.join
      end

      def dates_to_range(date_left,date_right)
        left = Time.utc(-2037,01  ,01,00,00).to_i
        right = Time.utc(2037,12,31,23,59).to_i
        left = time_local_from(date_left) unless date_left.blank?
        right = time_local_from("#{date_right} 23:59") unless date_right.blank?
        left..right
      end

      def time_local_from(datetime)
        date = datetime.split
        parsed_date = date_parser(date[0])
        date_args = [parsed_date[:year], parsed_date[:month], parsed_date[:day]]
        date_args += date[1].split(':').collect{ |hm| hm.to_i } unless date[1].blank?
        DateTime.civil(*date_args).to_f.to_i
      end

      def date_parser(date)
        parsed_date = {}
        date_string = date.split('/')
        if I18n.locale == :en
          parsed_date[:day] = date_string[1].to_i
          parsed_date[:month] = date_string[0].to_i
          parsed_date[:year] = date_string[2].to_i

        elsif I18n.locale == :fr
          parsed_date[:day] = date_string[0].to_i
          parsed_date[:month] = date_string[1].to_i
          parsed_date[:year] = date_string[2].to_i

        elsif I18n.locale == :cn
          parsed_date[:day] = date_string[2].to_i
          parsed_date[:month] = date_string[1].to_i
          parsed_date[:year] = date_string[0].to_i

        else
          parsed_date[:day] = date_string[0].to_i
          parsed_date[:month] = date_string[1].to_i
          parsed_date[:year] = date_string[2].to_i

        end
        parsed_date
      end
    end

  end
end
