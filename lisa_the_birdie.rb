# https://github.com/muffinista/chatterbot
# http://rdoc.info/gems/twitter/Twitter/REST/Favorites#favorite-instance_method
# https://dev.twitter.com/docs/api/1.1

require 'rubygems'
require 'chatterbot/dsl'
require 'parse-ruby-client'


# All utility methods which Lisa needs - but are not related to being a bird
module LisaToolbox

  SLEEP_AFTER_RATE_LIMIT_ENGAGED = 60*5 # 5 min
  SLEEP_GENERIC = 60 # secs


  # klass => :tweet || :user
  # obj => Tweet object or User object
  def stringify(obj, klass)
    if klass == :tweet
      data = {
        :id => obj.id,
        :text => obj.text,
        :stars => obj.favorite_count,
        :retweets => obj.retweet_count,
        :url => obj.url.to_s,
        :user_handle => obj.user.handle,
        :user_followers => obj.user.followers_count,
        :user_friends => obj.user.friends_count,
        :user_tweets => obj.user.tweets_count,
        :user_stars => obj.user.favorites_count,
        :user_url => obj.user.url.to_s
      }
    else
      data = {
        :id => obj.id,
        :user_handle => obj.handle,
        :user_followers => obj.followers_count,
        :user_friends => obj.friends_count,
        :user_tweets => obj.tweets_count,
        :user_stars => obj.favorites_count,
        :user_url => obj.url.to_s
      }
    end
    return data
  end



  # Helper method to loop
  def self.looper(&block)
    loop do
      puts "################################################################"
      puts "Starting Looper at #{Time.now}"

      block.call

      puts "Ending Looper at #{Time.now}"
      puts "################################################################"
    end
  end


  # Runs the given block of code in a new thread
  def self.run_in_new_thread(name, &block)
    puts "################################################################"
    puts "Starting Thread #{name} at #{Time.now}"

    # Don't wait for it to finish
    Thread.start do
      block.call
    end

    puts "Ending Thread #{name} at #{Time.now}"
    puts "################################################################"    
  end



  # Calls the given block with a sleeping factor of the rate limiting
  # Currently we don't care about the lost activity as we don't redo
  def rate_limit(where, &block)
    begin
      block.call
    rescue Twitter::Error::TooManyRequests => error
      puts "Rate limit engaged in #{where}, sleeping for #{error.rate_limit.reset_in} seconds #############################"
      sleep(error.rate_limit.reset_in + rand(SLEEP_AFTER_RATE_LIMIT_ENGAGED) + 10)
    rescue Exception => e
      puts "Got generic exception..."
      puts e
      puts e.backtrace
    end
  end  


  # Generic logging
  def log(message)
    puts "=> [#{Time.now.to_s.split(" ")[0..1].join(" ")}] #{message}"
  end


  # Min base will be added to all random sleeps
  def random_sleep(how_much = SLEEP_GENERIC, multiplier = 1, min_base = 0)
    sleep_for = rand(how_much * multiplier) + min_base
    puts "Randomly sleeping for #{sleep_for} seconds"
    sleep(sleep_for)
  end


  # Executes the given block after random time in a new thread
  def do_later(random_sleep_max_time = SLEEP_GENERIC, multiplier = 1, min_base = 0, &block)
    Thread.start do
      random_sleep(random_sleep_max_time, multiplier, min_base)
      block.call
    end
  end



  # klass => :starred, :followed
  # data => actual value to record. Tweet.id in case of starred, user.handle in case of followed
  def record_hit(klass, data)
    system("echo '#{data}' >> #{klass.to_s}.txt")
  end

  def check_hit?(klass, data)
    print "?"
    command = "grep '#{data}' #{klass.to_s}.txt 1>/dev/null"
    return system(command)
  end

end




# All methods which are required by Lisa to work with Parse
module LisaOnParse

  # klass => The class name
  # params => {k1=>v1, k2=>v2}
  # params[:handle] is an expected key for now - OR the object would be created as new
  # First searches for a unique reference of params[:handle] and then either updates the found object or creates new
  def save(klass, params)
    puts "Saving in Parse [#{klass}] : #{params.to_json}"

    raise if params[:handle] == nil
    
    obj = find(klass, {
            :find_by_key => "handle", # handle is the primary key for all save operations
            :find_by_value => params[:handle], 
            :limit => 1
          }).first

    obj = obj || Parse::Object.new(klass)
    params.each { |key, value|
      obj[key.to_s] = value
    }
    obj.save
    return obj
  end


  # klass => The class name
  # params => {:find_by_key=>"mentioned", :find_by_value=>true, :order_by_key=>"createdAt", :sort=>:descending, :limit=>1}
  def find(klass, config)
    objects = Parse::Query.new(klass).tap do |q|
      q.eq(config[:find_by_key], config[:find_by_value])
      q.order_by = config[:order_by_key]
      q.order    = config[:sort]
      q.limit    = config[:limit].to_i
    end.get

    return objects
  end

end




# A class which governs how Lisa responds to the user's incoming/outgoing personal communication
class LisaTheChattyBird
  include LisaToolbox

  attr_accessor :stream, :client, :myself

  # config is the same config object which is received by LisaTheBirdie
  def initialize(config_params)
    @config = config_params
    @stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = @config[:auth][:consumer_key]
      config.consumer_secret     = @config[:auth][:consumer_secret]
      config.access_token        = @config[:auth][:token]
      config.access_token_secret = @config[:auth][:secret]
    end

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = @config[:auth][:consumer_key]
      config.consumer_secret     = @config[:auth][:consumer_secret]
      config.access_token        = @config[:auth][:token]
      config.access_token_secret = @config[:auth][:secret]
    end

    @myself = @client.user.handle

    setup_event_loop
  end


  private


  def setup_event_loop

    @stream.user do |object|
      case object
        when Twitter::Tweet
          on_timeline_tweet(object)
        when Twitter::DirectMessage
          on_dm(object)
        when Twitter::Streaming::Event
          #puts object.name, object.name.class
          case object.name
            when :list_member_added
              on_list_member_added(object.source, object.target, object.target_object)
            when :favorite
              on_star(object.source, object.target, object.target_object)
            when :follow
              on_follow(object.source, object.target)
            when :unfollow
              puts "Unfollow from #{object.target.handle}"
          end
        when Twitter::Streaming::FriendList
          ;
        when Twitter::Streaming::StallWarning
          on_stall_warning
        else
          #puts object.id if object.class == Twitter::Streaming::DeletedTweet
          puts object, object.id, object.user_id
      end # case
    end   # stream

  end


  # On a star
  # Follow the source user if target is self
  def on_star(source, target, tweet)
    puts "--------------------------------------on_star--------------------------------------------"
    log("Got starred (source : #{source.handle}, target : #{target.handle}) : #{tweet.text}")
    log("#{target.handle} follows #{source.handle} ? : #{client.user(source.handle).following?}")  
    if @client.user(source.handle).following? == false && source.handle != @myself
      log("Will follow #{source.handle}")
      rate_limit(:on_star__follow) { @client.follow(source.handle) }
    end
    puts "--------------------------------------on_star--------------------------------------------"
  end


  # When a user is added to a list
  def on_list_member_added(source, target, list)
    log("Got new addition to list : #{target.handle}")
  end


  # On a follow
  # This event is invoked on all possible follow events - either to me or from me
  def on_follow(source, target)
    return if target.handle != @myself

    log("Follow event from #{source.handle}")
    
    message1 = "Hey! Thanks for following. Let's stay in touch."
    #message2 = "I forgot to mention the Yo! B*tch app we are working on. Would love your feedback on it. http://j.mp/yo_bitch"

    do_later(SLEEP_GENERIC, 2, SLEEP_GENERIC) { 
      puts "Sending DM1"
      @client.create_direct_message(source.handle, message1)
    }
  end


  # On a DM
  # This event is invoked on all possible follow events - either to me or from me
  def on_dm(message)
    log("DM : #{message.text}")
  end


  # On twitter's stall warning
  def on_stall_warning
    log("Stall warning from Twiiter")
  end


  # On a new timeline tweet
  def on_timeline_tweet(tweet)
  end

end





class LisaTheBirdie
  include LisaOnParse
  include LisaToolbox

  attr_accessor :config, :bird_food, :bird_food_stats

  SLEEP_AFTER_ACTION = 60 # secs
  SLEEP_AFTER_SHOUTOUT = 60*10 # 15 mins
  APP_URL = "http://j.mp/yo_bitch"
  PARSE_KLASS = "People"


  class BirdFood < Struct.new(:stuff, :operation)
  end



  def initialize(config = {})
    # Safety net
    raise if config[:auth][:consumer_key].nil? or config[:auth][:consumer_secret].nil? or config[:auth][:token].nil? or config[:auth][:secret].nil?
    raise if config[:parse][:application_id].nil? or config[:parse][:api_key].nil?

    default_config = {
      :auth => {
        :consumer_key => nil,
        :consumer_secret => nil,
        :token => nil,
        :secret => nil
      },
      :parse => {
        :application_id => nil,
        :api_key => nil
      },
      :lang => "en", 
      :tweet => {
        :min_retweet_count => 1, 
        :min_star_count => 1,
        :moderate_retweet_count => 2,
        :moderate_star_count => 2,  
        :high_retweet_count => 4,
        :high_star_count => 4   # To get more starrable tweets into the honeypot :)
      },
      :user => {
        :followers_to_friends_ratio => 0.3,
        :min_followers_count => 250,
        :min_star_count => 25,
        :min_tweet_count => 1000,
        :account_age => 0
      },
      :exclude => [] # Array of strings
    }

    @config = default_config.merge(config)

    # Setup the client
    consumer_key(@config[:auth][:consumer_key])
    consumer_secret(@config[:auth][:consumer_secret])
    token(@config[:auth][:token])
    secret(@config[:auth][:secret])

    no_update

    @bird_food = []
    @bird_food_stats = {
      :starrable => 0,
      :clonable => 0,
      :retweetable => 0,
      :followable => 0
    }

    setup_exclusions(@config[:exclude])

    Parse.init :application_id => config[:parse][:application_id],
               :api_key        => config[:parse][:api_key]     
  end




  # Searches and then eats the infested tweets/users
  def feast_on_keywords(keywords, operations = nil)
    operations = {:starrable => true, :retweetable => true, :clonable => true, :followable => true} if operations == nil
    bird_food = search_tweets(keywords, operations)

    # Process all bird food and call their related methods
    length = bird_food.length
    bird_food.each_with_index { |food_item, index|
      log "-------------------------------------------------------------------"
      log "Processing [#{index}/#{length}] tweet/user for #{food_item.operation}"
      self.send(food_item.operation, food_item.stuff)
    }
  end



  # NOTE - Actually does the stars
  def star(tweet)
    log("Starring tweet (id=>#{tweet.id}) : [#{tweet.user.handle}] : #{tweet.text}")
    rate_limit(:star) { client.favorite(tweet.id) }
    save(PARSE_KLASS, 
          {:handle => tweet.user.handle, :mentioned => false, :followed => false, :starred => true})
    record_hit(:tweet_infested, tweet.id)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION)
  end


  # NOTE - Actually does the retweet
  def retweet(tweet)
    log("Retweeting tweet (id=>#{tweet.id}) : [#{tweet.user.handle}] : #{tweet.text}")
    rate_limit(:retweet) { client.retweet(tweet.id) }
    record_hit(:tweet_infested, tweet.id)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION)
  end


  # NOTE - Actually does the clone
  def clone(tweet)
    log("Cloning tweet (id=>#{tweet.id}) : [#{tweet.user.handle}] : #{tweet.text}")
    rate_limit(:clone) { client.update(tweet.text) }
    record_hit(:tweet_infested, tweet.id)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION)
  end    


  # NOTE - Actually does the follow
  def follow(user, do_save = true)
    log("Following user : [#{user.handle}]")
    rate_limit(:follow) { client.follow(user.handle) }
    save(PARSE_KLASS, 
          {:handle => user.handle, :mentioned => false, :followed => true, :starred => false}) if do_save == true
    record_hit(:followed, user.handle)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION)
  end



  # Picks up any friend or follower and asks them to try out the app, then follows them
  # Sleeps for SLEEP_AFTER_SHOUTOUT seconds after each shoutout
  def shoutout_for_app_feedback
    media_files = ["./media/twitter_media1.png", "./media/twitter_media2.png"]
    tweet_templates = [
      "A shoutout to __USER__ : try our Yo! B*tch android app, primed for bitching : #{APP_URL}",
      "__USER__ would love your feedback on our Yo! B*tch app : #{APP_URL}",
      "__USER__ : what's your take on our Yo! B*tch android app : #{APP_URL}",
      "__USER__ try our Yo! B*tch android app : #{APP_URL}",
      "Love bitching? __USER__, try our Yo! B*tch android app : #{APP_URL}",
      "__USER__ checkout our Yo! B*tch android app : #{APP_URL}",
      "__USER__, have you tried our Yo! B*tch android app : #{APP_URL}",
      "Bitching made fun! __USER__, try our Yo! B*tch android app : #{APP_URL}",
      "Seeking feedback on our app __USER__. Yo! B*tch app : #{APP_URL}",
      "Bitching at friends made fun. __USER__ Try our Yo! B*tch android app : #{APP_URL}"
    ]

    user = find(PARSE_KLASS, {
                :find_by_key => "mentioned", 
                :find_by_value => false, 
                :order_by_key => "createdAt", 
                :sort => :descending, 
                :limit => 1
              }).first

    return if user == nil

    media = media_files[rand(media_files.length)]
    tweet = tweet_templates[rand(tweet_templates.length)]

    tweet.gsub!("__USER__", "@#{user["handle"]}")
    puts tweet
    rate_limit(:shoutout_for_app_feedback) { 
      Time.now.to_i % 3 == 0 ? client.update_with_media(tweet, File.new(media)) : client.update(tweet)
      random_sleep(SLEEP_AFTER_ACTION, 2)
      follow(client.user(user["handle"]), false)
      save(PARSE_KLASS, {:mentioned => true, :followed => true, :handle => user["handle"]})
    }

    random_sleep(SLEEP_AFTER_SHOUTOUT, 1, SLEEP_AFTER_SHOUTOUT)
  end



  private


  # Search based on an array of given keywords
  # operations => {:starrable => true, :retweetable => true, :clonable => true, :followable => true}
  def search_tweets(keywords, operations)
    search_text = keywords.length > 1 ? keywords.join(" OR ") : keywords.first
    puts "\n======================================================"
    puts "Searching for #{search_text}"

    original_search_count = 0
    rate_limit(:search) {
      search(search_text, :lang => @config[:lang]) do |tweet| 
        original_search_count += 1
        #puts stringify(tweet, :tweet)
        if is_tweet_of_basic_interest?(tweet) == true
          rate_limit(:search_tweets) {
            if operations[:starrable] == true and is_starrable?(tweet) == true
              @bird_food << BirdFood.new(tweet, :star) 
              @bird_food_stats[:starrable] += 1
            end

            if operations[:retweetable] == true and is_retweetable?(tweet) == true
              @bird_food << BirdFood.new(tweet, :retweet) 
              @bird_food_stats[:retweetable] += 1
            end

            if operations[:clonable] == true and is_clonable?(tweet) == true
              @bird_food << BirdFood.new(tweet, :clone) 
              @bird_food_stats[:clonable] += 1
            end

            if operations[:followable] == true and is_followable?(tweet.user) == true
              @bird_food << BirdFood.new(tweet.user, :follow) 
              @bird_food_stats[:followable] += 1
            end
          } # rate limit
        end
      end
    }

    puts "\nOriginal search count : #{original_search_count}, infestable : #{@bird_food.length}"
    puts @bird_food_stats.to_json
    return @bird_food.shuffle!
  end  




  # TODO - relook into this
  def setup_exclusions(custom_exclude_list = [])
    default_exclusion = ["money", "spammer", "junk", "spam", "fuck", "pussy", "ass", "shit", "piss", "cunt", "mofo", "cock", "tits", "wife", "sex", "porn"]
    exclude(default_exclusion + custom_exclude_list)
  end



  # Figure out which tweet to infest on
  # TODO - how do we check if this is not a dup interaction on the user?
  def is_tweet_of_basic_interest?(tweet)
    # Don't process the tweet if we have already infested it before
    return false if check_hit?(:tweet_infested, tweet.id) == true

    score = 0
    score += 1 if tweet.retweet_count >= @config[:tweet][:min_retweet_count] 
    score += 1 if tweet.favorite_count >= @config[:tweet][:min_star_count] 

    return score > 1 ? true : false
  end  


  # If tweet is worthy of a star
  def is_starrable?(tweet)
    # Not a reply, High star count
    if tweet.favorite_count >= @config[:tweet][:high_star_count] \
          and tweet.reply? == false
      return true
    end
    return false
  end


  # If tweet is worthy of being retweeted
  def is_retweetable?(tweet)
    # Not a reply, High retweet count, moderate star count
    if ((tweet.favorite_count >= @config[:tweet][:moderate_star_count] \
              and tweet.retweet_count >= @config[:tweet][:high_retweet_count]  \
              and tweet.reply? == false)) \
          or (is_followable?(tweet.user) == true)
      return true
    end
    return false
  end


  # If tweet is worthy of being clonable (copy=>paste basically)
  def is_clonable?(tweet)
    # Not a reply, Min star count, High retweet count
    if (tweet.favorite_count >= @config[:tweet][:min_star_count] \
          and tweet.retweet_count >= @config[:tweet][:moderate_retweet_count]  \
          and tweet.reply? == false)
      return true
    end
    return false
  end


  # If the user who tweeted the tweet is followable
  def is_followable?(user)
    return false if user.following? == true

    # Friend to following ratio, stars, tweet count, min followers, since on twitter
    # Should not be following the user already
    followers_count = user.followers_count
    friends_count = user.friends_count
    stars_count = user.favorites_count
    tweets_count = user.tweets_count
    account_age = 0 # TODO

    followers_to_friends_ratio = (friends_count != 0 ? (followers_count/friends_count).to_f : 0)

    if followers_to_friends_ratio >= @config[:user][:followers_to_friends_ratio]  \
        and stars_count >= @config[:user][:min_star_count] \
        and tweets_count >= @config[:user][:min_tweet_count] \
        and followers_count >= @config[:user][:min_followers_count]  \
        and account_age >= @config[:user][:account_age]
      
      # Only follow if the user is not already being followed
      if check_hit?(:followed, user.handle) == false
        return true
      else
        #puts "Found dup hit in is_followable? @#{user.handle} ================================="
      end        
    end

    return false
  end


end






