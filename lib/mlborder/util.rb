module Mlborder
  class Util
    def self.number_format(number)
      number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    end

    def self.border_number(border_text)
      border_text.sub('border_', '').to_i
    end
  end
end
