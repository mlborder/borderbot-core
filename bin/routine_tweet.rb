require 'rbatch'

args = ARGV.getopts('s:d')
series_name = args['s'] || 'sample'
debug_flg = args['d']

datastore = Mlborder::Datastore.new
bot = Mlborder::TwitterBot.new debug_flg

series = datastore.fetch_data series_name, Time.new

current_data = series.first
past_data = series.last

border_list = []
current_data.select{|key, value| key.include?('border_') && !value.nil? }
            .sort{|a, b| Mlborder::Util.border_number(a.first) <=> Mlborder::Util.border_number(b.first)}.each do |border, point|
  border_list << { rank: Mlborder::Util.border_number(border), point: point, velocity: (point - past_data[border]) } unless past_data[border].nil?
end

current_time = Time.at current_data['time']
tweet_txt = "『#{Mlborder::Util.event_name current_time}』\n#{current_time.strftime('%m/%d %H:%M')} #imas_ml\n"
rank_list = RBatch.common_config['MLBORDER_PRIZE_RANK_LIST']

border_list.select{|border| rank_list.include? border[:rank]}.each do |border|
  tweet_txt += "#{border[:rank]}位 #{Mlborder::Util.readable_unit border[:point]}pt/+#{Mlborder::Util.scalable_unit border[:velocity]}\n"
end
tweet_txt += "\n参考:https://mlborder.herokuapp.com/"

bot.tweet tweet_txt
