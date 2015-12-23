module Mlborder
  class Datastore
    @influxdb_cli = nil

    def initialize
      @influxdb_cli = InfluxDB::Client.new( RBatch.common_config["INFLUXDB_DATABASE"],
                                            host: RBatch.common_config["INFLUXDB_HOST"],
                                            port: RBatch.common_config["INFLUXDB_PORT"],
                                            username: RBatch.common_config["INFLUXDB_USER"],
                                            password: RBatch.common_config["INFLUXDB_PASS"] )
    end

    def push_from_file(series_name, file_name)
      data_list = []

      open(file_name) do |file|
        buffer = []
        last_data = {}
        file.readlines.each do |l|
          l.force_encoding('UTF-8')
          buffer.push(l.gsub(/(\n|\r\n)/, ''))

          next unless buffer.last.include?('※')

          data = parse buffer
          next if data[:time] == last_data[:time]
          last_data = data

          data_list.push(data)
          @influxdb_cli.write_point(series_name, data)
          buffer.clear
        end
      end

      data_list
    end

    def fetch_data(series_name, target_time, duration = 3600)
      str_time_to = target_time.to_i
      str_time_from = str_time_to - duration - 300
      ret = @influxdb_cli.query "SELECT * FROM \"#{series_name}\" WHERE time <= #{str_time_to}s AND time >= #{str_time_from}s"
      values = ret.first['values'].reverse

      index = -1
      latest_time = Time.parse(values.first['time'])
      values.each_with_index do |data, i|
        if (latest_time.to_i - Time.parse(data['time']).to_i) >= duration
          index = i
          break
        end
      end
      values[0..index]
    end

    private
    def parse(packet)
      meta_data = packet.pop
      str_date = meta_data.match(/\d{1,2}\/\d{1,2}/).to_s
      str_time = meta_data.match(/\d{1,2}:\d{1,2}/).to_s

      updated_at = Time.strptime("%s %s"%[str_date, str_time], "%m/%d %H:%M")

      ret = { time: updated_at.to_i }
      packet.each do |line|
        rank, point = line.split(':')
        ret["border_#{rank}".to_sym] = point.gsub(',', '').to_i
      end
      ret[:updated_at] = updated_at
      ret
    end
  end
end
