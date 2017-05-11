module Mlborder
  class TwitterBot
    @bot = nil
    @debug_mode = false

    def initialize(debug_mode = false)
      @debug_mode = debug_mode
      return if debug_mode

      require 'twitter'
      require 'mastodon'

      @bot = Twitter::REST::Client.new(
        consumer_key:        RBatch.common_config['TWITTER_CONSUMER_KEY'],
        consumer_secret:     RBatch.common_config['TWITTER_CONSUMER_SECRET'],
        access_token:        RBatch.common_config['TWITTER_ACCESS_TOKEN'],
        access_token_secret: RBatch.common_config['TWITTER_ACCESS_TOKEN_SECRET']
      )
      @mastodon_cli = Mastodon::REST::Client.new(
        base_url:           RBatch.common_config['MASTODON_BASE_URL'],
        bearer_token:       'd732346e952bf94b61ded850f27789c4efdfd3065461c0f9949fc8dd4efee27a'#RBatch.common_config['MASTODON_BEARER_TOKEN']
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

    def toot(toot_str, in_reply_to_id = nil)
      return if debug_mode?

      unless in_reply_to_id.nil?
        @mastodon_cli.create_status toot_str, in_reply_to_id
      else
        @mastodon_cli.create_status toot_str
      end
    end

    def search_user(user_id)
      @bot.user user_id unless debug_mode?
    end

    def debug_mode?
      @debug_mode
    end
  end
end
