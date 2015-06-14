require 'rbatch'

args = ARGV.getopts('s:d')
series_name = args['s'] || 'sample'
debug_flg = args['d']

datastore = Mlborder::Datastore.new
bot = Mlborder::TwitterBot.new debug_flg

beginning_of_day = Time.parse(Time.now.strftime("%Y-%m-%d 00:00:00"))
series = datastore.fetch_data series_name, beginning_of_day, 60 * 60 * 24

current_data = series.first
past_data = series.last
start_time = Time.at past_data['time']
end_time = Time.at current_data['time']
hours = (end_time.to_i - start_time.to_i) / 3600.0

border_list = []
current_data.select{|key, value| key.include?('border_') && !value.nil? }
            .sort{|a, b| Mlborder::Util.border_number(a.first) <=> Mlborder::Util.border_number(b.first)}.each do |border, point|
  border_list << { rank: Mlborder::Util.border_number(border), point: point, velocity: (point - past_data[border]) } unless past_data[border].nil?
end

rank_list = RBatch.common_config['MLBORDER_PRIZE_RANK_LIST']
border_tweet = border_list.select{|border| rank_list.include? border[:rank]}.map do |border|
  "#{border[:rank]}位 #{Mlborder::Util.readable_unit border[:point]}pt/日速#{Mlborder::Util.scalable_unit border[:velocity]}/時速#{Mlborder::Util.scalable_unit (border[:velocity] / hours).to_i}"
end

tweet_txt = "『#{Mlborder::Util.event_name start_time}』\n"
tweet_txt += "日次集計:#{start_time.strftime('%d日%H:%M')}〜#{end_time.strftime('%d日%H:%M')}\n"
tweet_txt += border_tweet.join("\n")

tweet_txt += "\n参考:https://mlborder.herokuapp.com/"

bot.tweet tweet_txt
