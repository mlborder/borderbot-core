module Mlborder
  class Event
    attr_reader :name, :start_time, :end_time

    def initialize(event_hash)
      @name = event_hash['name']
      @start_time = Time.parse(event_hash['started_at']) unless event_hash['started_at'].nil?
      @end_time = Time.parse(event_hash['ended_at']) unless event_hash['ended_at'].nil?
    end

    def progress_at(time)
      return if time.nil?
      return if self.start_time.nil?
      return if self.end_time.nil?

      (time.to_i - start_time.to_i).to_f / (end_time.to_i - start_time.to_i)
    end

    def self.explore_by_time(time)
      self.new(self.fetch_event_json_with_cache(time))
    end

    private
    def self.fetch_event_json_with_cache(time)
      event = open(event_json_cache_path, 'r') do |f|
        event = JSON.parse(f.read.force_encoding('UTF-8'))
        start_time = Time.parse(event['started_at'])
        end_time = Time.parse(event['ended_at'])
        raise unless (start_time..end_time).cover?(time)
        event
      end
    rescue
      fetch_event_json
    end

    def self.fetch_event_json
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
