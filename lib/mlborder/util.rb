module Mlborder
  class Util
    def self.number_format(number)
      number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    end

    def self.border_number(border_text)
      border_text.sub('border_', '').to_i
    end

    def self.event_name(time)
      name = nil
      open(event_json_cache_path, 'r') do |f|
        event = JSON.parse(f.read.force_encoding('UTF-8'))
        start_time = Time.parse(event['started_at'])
        end_time = Time.parse(event['ended_at'])
        raise unless (start_time..end_time).cover?(time)
        name = event['name']
      end
      name
    rescue
      update_event_json
    end

    private
    def self.update_event_json
      uri = RBatch.common_config['MLBORDER_EVENT_SOURCE']
      puts "Loading event_info from #{uri} and updating..."

      body = open(uri).read
      open(event_json_cache_path, 'w') { |f| f.puts body }
      event = JSON.parse(body)
      event['name']
    rescue => e
      '現在開催中のイベント'
    end

    def self.event_json_cache_path
      "#{ENV['PWD']}/tmp/event_info.cache"
    end
  end
end
