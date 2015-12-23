module Mlborder
  class Util
    def self.number_format(number)
      number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    end

    def self.border_number(border_text)
      border_text.sub('border_', '').to_i
    end

    def self.readable_unit(number)
      digit = number.to_i.to_s.length
      digit_limit = 4
      num, unit = if digit < 10_000.to_s.length
                    [number, '']
                  elsif digit < 100_000_000.to_s.length
                    [(number / 10_000.0).round(4), '万']
                  else
                    [(number / 100_000_000.0).round(4), '億']
                  end

      after_digit = num == num.to_i ? 0 : digit_limit - num.to_i.to_s.length
      after_digit <= 0 ? "#{num.to_i}#{unit}" : "#{format("%.#{after_digit}f", num)}#{unit}"
    end

    def self.scalable_unit(number)
      digit = number.to_s.length
      digit_limit = 4
      num, unit = if digit < 4
                    [number, '']
                  elsif digit < 7
                    [(number / 1_000.0).round(4), 'k']
                  elsif digit < 10
                    [(number / 1_000_000.0).round(4), 'M']
                  else
                    [(number / 1_000_000_000.0).round(4), 'G']
                  end

      after_digit = num == num.to_i ? 0 : digit_limit - num.to_i.to_s.length
      after_digit <= 0 ? "#{num.to_i}#{unit}" : "#{format("%.#{after_digit}f", num)}#{unit}"
    end
  end
end
