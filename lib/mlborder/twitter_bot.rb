module Mlborder
  class TwitterBot
    @bot = nil
    @debug_mode = false

    def initialize(debug_mode = false)
      @debug_mode = debug_mode
      return if debug_mode

      require 'twitter'

      @bot = Twitter::REST::Client.new(
        consumer_key:        RBatch.common_config['TWITTER_CONSUMER_KEY'],
        consumer_secret:     RBatch.common_config['TWITTER_CONSUMER_SECRET'],
        access_token:        RBatch.common_config['TWITTER_ACCESS_TOKEN'],
        access_token_secret: RBatch.common_config['TWITTER_ACCESS_TOKEN_SECRET']
      )
    end

    def tweet(tweet_str, in_reply_to_status_id = nil)
      if debug_mode?
        RBatch::Log.new do |logger|
          puts "tweet:\n#{tweet_str}\nlength:#{tweet_str.length}"
        end
      else
        unless in_reply_to_status_id.nil?
          @bot.update tweet_str, in_reply_to_status_id
        else
          @bot.update tweet_str
        end
      end
    end

    def debug_mode?
      @debug_mode
    end
  end
end
