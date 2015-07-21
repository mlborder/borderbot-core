module Mlborder
  class Util
    def self.number_format(number)
      number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    end

    def self.border_number(border_text)
      border_text.sub('border_', '').to_i
    end

    def self.readable_unit(number)
      digit = number.to_s.length
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

    def self.event_at(time)
      event = open(event_json_cache_path, 'r') do |f|
        event = JSON.parse(f.read.force_encoding('UTF-8'))
        start_time = Time.parse(event['started_at'])
        end_time = Time.parse(event['ended_at'])
        raise unless (start_time..end_time).cover?(time)
        event
      end
    rescue
      update_event_json
    end

    private
    def self.update_event_json
      uri = RBatch.common_config['MLBORDER_EVENT_SOURCE']
      puts "Loading event_info from #{uri} and updating..."

      body = open(uri).read
      open(event_json_cache_path, 'w') { |f| f.puts body }
      JSON.parse(body)
    rescue => e
      { 'name' => '現在開催中のイベント',
        'started_at' => nil,
        'ended_at' => nil
      }
    end

    def self.event_json_cache_path
      "#{ENV['PWD']}/tmp/event_info.cache"
    end
  end
end
