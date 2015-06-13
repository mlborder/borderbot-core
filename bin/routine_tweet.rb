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
current_data.select{|key| key.include? 'border_' }.sort{|a, b| Mlborder::Util.border_number(a.first) <=> Mlborder::Util.border_number(b.first)}.each do |border, point|
  next if point.nil?
  border_list << { rank: Mlborder::Util.border_number(border), point: point, velocity: (point - past_data[border]) } unless past_data[border].nil?
end

current_time = Time.at current_data['time']
tweet_txt = "#{current_time.strftime('%m/%d %H:%M')} #imas_ml\n"
border_list.each do |border|
  next unless [100,1200].include? border[:rank]
  tweet_txt += "#{border[:rank]}位 #{Mlborder::Util.number_format border[:point]}pt/+#{Mlborder::Util.number_format border[:velocity]}\n"
end
tweet_txt += "\n参考:https://mlborder.herokuapp.com/"

bot.tweet tweet_txt
