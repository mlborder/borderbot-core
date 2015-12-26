require 'rbatch'

args = ARGV.getopts('d')
debug_flg = args['d']
current_time = Time.now

influxdb = Mlborder::Datastore.new
postgres = Mlborder::Postgres.new
bot = Mlborder::TwitterBot.new debug_flg
event = Mlborder::Event.explore_by_time(current_time)

if ((event.start_time)..(event.end_time)).cover? current_time
  alarms = postgres.cli.exec \
    "SELECT * FROM users INNER JOIN alarms ON users.id = alarms.user_id WHERE alarms.event_id = #{event.id} AND alarms.status = 1"

  if alarms.any?
    recent = influxdb.fetch_just_recent_data(event.series_name)
    update_time = Time.parse(recent['time'])

    ids = []
    alarms.each do |alarm|
      next if alarm['provider'] != 'twitter'
      next unless recent["border_#{alarm['rank']}"]
      next if alarm['value'].to_i > recent["border_#{alarm['rank']}"].to_i

      user = bot.search_user(alarm['uid'].to_i)
      screen_name = debug_flg ? alarm['screen_name'] : user.screen_name

      ids << alarm['id'].to_i
      bot.tweet <<-TWEET
@#{screen_name}
【ボーダーお知らせ：#{update_time.localtime('+09:00').strftime('%m/%d %H:%M')}更新】
#{alarm['rank']}位のボーダーが#{alarm['value'].to_i}ptを超えました(現在:#{recent["border_#{alarm['rank']}"].to_i}pt)
『#{event.name}』
TWEET
    end

    if debug_flg
      p ids
    else
      postgres.cli.exec "UPDATE alarms SET status = 2 WHERE id IN (#{ids.join(',')})" if ids.any?
    end
  end
  postgres.cli.finish
end
