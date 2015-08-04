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
current_event = Mlborder::Event.explore_by_time(current_time)
progress = current_event.progress_at(current_time)
str_progress = progress.nil? ? '' : "(#{(progress * 100).round(1)}%)"

tweet_txt = "『#{current_event.name}』\n#{current_time.strftime('%m/%d %H:%M')}#{str_progress} #imas_ml\n"
rank_list = RBatch.common_config['MLBORDER_PRIZE_RANK_LIST']

border_list.select{|border| rank_list.include? border[:rank]}.each do |border|
  tweet_txt += "#{border[:rank]}位 #{Mlborder::Util.readable_unit border[:point]}/+#{Mlborder::Util.readable_unit border[:velocity]}\n"
end
tweet_txt += "\n参考:https://mlborder.herokuapp.com/"

bot.tweet tweet_txt
