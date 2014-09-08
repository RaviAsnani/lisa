require 'rubygems'
require 'chatterbot/dsl'
require 'parse-ruby-client'
require "pp"
require "google-search"     # used for image search
require "cgi"               # for unescaping html entities
require "googl"
require "mail"

require "./libs/google/curbemu.rb"
require "./libs/google/ruby-web-search.rb"
require "./libs/maku/google_image_search.rb"




# All utility methods which Lisa needs - but are not related to being a bird
module LisaToolbox

  SLEEP_AFTER_RATE_LIMIT_ENGAGED = 60*5 # 2 min
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
    puts "Pre Thread #{name} at #{Time.now}"

    # Don't wait for it to finish
    thread = Thread.start do
      block.call
    end

    puts "Post Thread #{name} at #{Time.now}"
    puts "################################################################"   

    return thread 
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
  def log(object, prefix="log")
    prefix.upcase!
    timestamp = Time.now.to_s.split(" ")[0..1].join(" ")
    if object.is_a?(Twitter::Tweet)
      pre = "[#{prefix}] [#{timestamp}] [ST:#{object.favorite_count}, RT:#{object.retweet_count}, urls?:#{object.urls?}, media?:#{object.media?}, @M?:#{object.user_mentions?}] : [@#{object.user.id}:#{object.user.handle}]"
      puts "\n=> #{pre} => #{object.text}" 
    elsif object.is_a?(Twitter::User)
      pre = "[#{prefix}] [#{timestamp}] [Fo:#{object.followers_count}, Fr:#{object.friends_count}, \
              Fo/Fr:#{object.followers_count/object.friends_count.to_f}, St:#{object.favorites_count}, \
              Tw:#{object.tweets_count}] Handle=#{object.handle}"
      puts "\n=> #{pre}"       
    else
      puts "\n=> [#{prefix}] [#{timestamp}] #{object}"
    end
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

  # returns true if data was found for the klass
  def check_hit?(klass, data, verbosity=:silent)
    print "."
    command = "grep '#{data}' #{klass.to_s}.txt 1>/dev/null"
    result = system(command)
    puts "check_hit? was #{result} for #{klass}" if verbosity == :verbose
    return result
  end


  # Download a web url to disk
  def download_url(url, output_filename, dir_name = "media/tmp")
    command = "wget --quiet '#{url}' -O '#{dir_name}/#{output_filename}'"
    system(command)
  end


  # For a given base, return base+rand(x)
  def with_x_percentage_additional_random(base, x_percentage)
    random_x_percentage = rand(x_percentage)
    return (base + (random_x_percentage*base/100)).to_i
  end


  # Send the email
  def mail(from, to, subject, body)
    raise if from.nil? or to.nil? or subject.nil? or body.nil?

    # Send the email now
    Mail.deliver do
      from     from
      to       to
      subject  subject
      body     body
    end
  end  


end




# Holds tweets & users of interest
class BirdFood < Struct.new(:stuff, :operations, :user_handle)
  include LisaToolbox

  # Custom to_s
  def to_s
    log(stuff, operations.to_json)
  end


  # Returns the list of operations if a given tweet is selected for more than one operation
  # => [:starrable, :followable]
  # :starrable=4, :clonable=2, :retweetable=1 (use Unix's RWX mechanism for calculating the final outcome)
  def get_primary_operations
    sum = 0
    sum += 4 if operations[:starrable] == true
    sum += 2 if operations[:clonable] == true
    sum += 1 if operations[:retweetable] == true

    primary_operations = []

    case sum
      when 4 # only star
        primary_operations << :star
      when 2 # only clone
        primary_operations << :clone
      when 1 # only retweet
        primary_operations << :retweet
      when 6 # star + clone
        primary_operations << :star
      when 7 # star + clone + retweet
        primary_operations << :clone
      when 3 # clone + retweet
        primary_operations << :retweet
    end # case

    # Issue :follow as a primary operation only if there exists another primary operation along with follow
    primary_operations << :follow if operations[:followable] == true and sum != 0

    # If nothing else works, return the first available operation
    return primary_operations
  end
  
end   # BirdFood




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




# Tries to walk through the friends graph
class LisaPeopleBrowser
  include LisaToolbox

  def initialize(client = nil)
    raise if client.nil? == true
    @client = client  
  end


  # Returns all friends's usr ids of a given user id
  # returns => [id1, id2, id3]
  def find_all_friends_of(user_id)
    friends = []
    rate_limit(:LisaPeopleBrowser__find_all_friends_of) { 
      friends = @client.friend_ids(user_id).to_h[:ids]
    }
    return friends
  end


  # user_nadles => ["makuchaku", "yobitchme", ...]
  def find_all_friends_of_handles(user_handles=[])
    all_friends = []
    user_handles.each { |user_handle|
      user_id = @client.user(user_handle).id
      all_friends += find_all_friends_of(user_id)
    }
    return all_friends
  end  


  # # Find friends of a given user id => then find friends of each of those friends
  # # Currently, works only at level 2
  # # returns => [id1, id2, id3]
  # def find_deeply_nested_friends_of(user_id)
  #   all_friends = []
  #   all_friends = find_all_friends_of(user_id)
  #   all_friends.each { |friend|
  #     all_friends += find_all_friends_of(friend)
  #   }
  #   return all_friends
  # end

end




# A class which governs how Lisa responds to the user's incoming/outgoing personal communication
class LisaTheChattyBird
  include LisaToolbox

  attr_accessor :stream, :client, :myself, :live_tweets

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
    @people_browser = LisaPeopleBrowser.new(@client)

    config_params[:parse] = {
                              :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
                              :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
                            }   
    @lisa = LisaTheBirdie.new(config_params)   
    @live_tweets = []                         
  end


  # Monitors realtime conversation of the current user
  def start_chatting
    setup_user_event_loop
  end


  # Monitors realtime conversation of friends of X,y,z users
  def start_chatting_with_friends_of(user_handles=[])
    puts "Finding who #{user_handles} follows..."
    friends = @people_browser.find_all_friends_of_handles(user_handles)
    puts "Total people #{user_handles} follows = #{friends.length}"
    start_delayed_tweet_processor
    setup_friends_event_loop(friends)
  end


  private


  # Streaming events for friends of given users
  def setup_friends_event_loop(friend_ids)
    follow_filter = friend_ids.shuffle[0...1000].join(",")
    @stream.filter({:follow => follow_filter}) {|object| 
      common_event_loop(object, :general, {:friend_ids => friend_ids})
    }    
  end



  # Streaming events for myself
  def setup_user_event_loop
    @stream.user do |object|
      common_event_loop(object, :user)
    end  # stream
  end


  # mode => :user || :general
  def common_event_loop(object, mode, data = {})
    case object
      when Twitter::Tweet
        on_user_timeline_tweet(object) if mode == :user
        on_general_tweet(object, data[:friend_ids]) if mode == :general
      when Twitter::DirectMessage
        on_user_dm(object)  if mode == :user
      when Twitter::Streaming::Event
        if(mode == :user)
          #puts object.name, object.name.class
          case object.name
            when :list_member_added
              on_user_list_member_added(object.source, object.target, object.target_object)
            when :favorite
              on_user_star(object.source, object.target, object.target_object)
            when :follow
              on_user_follow(object.source, object.target)
            when :unfollow
              puts "Unfollow from #{object.target.handle}"
          end
        end # mode=:user
      when Twitter::Streaming::FriendList
        ;
      when Twitter::Streaming::StallWarning
        on_user_stall_warning(mode)
      else
        #puts object.id if object.class == Twitter::Streaming::DeletedTweet
        puts object, object.id, object.user_id
    end # case
  end


  # When a tweet is received if mode==:general
  def on_general_tweet(object, friend_ids)
    print "~"
    if object.is_a?(Twitter::Tweet) and friend_ids.index(object.user.id) != nil
      process_live_tweet(object)
    end      
  end




  # Push the live tweets into an queue for later processing
  def process_live_tweet(tweet)
    if @lisa.is_tweet_of_basic_interest?(tweet, :live) == true
      #log(tweet)

      # @live_tweets << BirdFood.new(tweet, :clone)  if @lisa.is_clonable?(tweet, :live) == true
      # @live_tweets << BirdFood.new(tweet, :retweet)  if @lisa.is_retweetable?(tweet, :live) == true
      # @live_tweets << BirdFood.new(tweet, :star)  if @lisa.is_starrable?(tweet, :live) == true

      @live_tweets << BirdFood.new(tweet, {
        :clonable => @lisa.is_clonable?(tweet, :live),
        :retweetable => @lisa.is_retweetable?(tweet, :live),
        :starrable => @lisa.is_starrable?(tweet, :live),
        :followable => false #@lisa.is_followable?(tweet.user, :live)  # Don't engage in following from here - can lead to very bad bans (as all the people will generally be of high quality)
      }, tweet.user.handle)

      print "Q"
    end #if
  end



  # Start queue processing
  def start_delayed_tweet_processor
    LisaToolbox.run_in_new_thread(:delayed_tweet_processor) {
      while true
        food_item = @live_tweets.shift
        # Sleep if there is nothing in the queue. Execute it otherwise
        if food_item.nil?
          random_sleep
        else
          food_item.get_primary_operations.each { |operation|
            if operation == :follow
              @lisa.send(operation, food_item.stuff.user, true, :real)
            else
              @lisa.send(operation, food_item.stuff, :real)
            end
          }
        end # if
      end # while
    }
  end



  # On a star
  # Follow the source user if target is self
  def on_user_star(source, target, tweet)
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
  def on_user_list_member_added(source, target, list)
    log("Got new addition to list : #{target.handle}")
  end


  # On a follow
  # This event is invoked on all possible follow events - either to me or from me
  def on_user_follow(source, target)
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
  def on_user_dm(message)
    log("DM : #{message.text}")
  end


  # On twitter's stall warning
  def on_user_stall_warning(mode)
    log("Streaming stall warning from Twiiter, mode => #{mode}")
  end


  # On a new timeline tweet
  def on_user_timeline_tweet(tweet)
  end

end





class LisaTheBirdie
  include LisaOnParse
  include LisaToolbox

  attr_accessor :config, :bird_food_stats, :exclude_list

  # random_sleep_time = rand(SLEEP_AFTER_ACTION * multiplier) + SLEEP_AFTER_ACTION_BASE
  SLEEP_AFTER_ACTION = 60 # secs
  SLEEP_AFTER_ACTION_BASE = 60*5 # secs

  SLEEP_AFTER_SHOUTOUT = 60*10 # 15 mins
  APP_URL = "http://j.mp/yo_bitch"


  def initialize(config = {})
    # Safety net
    raise if config[:auth].nil? or config[:parse].nil?
    raise if config[:auth][:consumer_key].nil? or config[:auth][:consumer_secret].nil? or config[:auth][:token].nil? or config[:auth][:secret].nil?
    raise if config[:parse][:application_id].nil? or config[:parse][:api_key].nil?

    default_config = {
      :name => "Lisa",
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
        :min_retweet_count => 2, 
        :min_star_count => 2,
        :moderate_retweet_count => 4,
        :moderate_star_count => 4,  
        :high_retweet_count => 6,
        :high_star_count => 6   # To get more starrable tweets into the honeypot :)
      },
      :user => {
        :followers_to_friends_ratio => 0.4,
        :min_followers_count => 500,
        :min_star_count => 25,
        :min_tweet_count => 1500,
        :account_age => 0
      },
      :exclude => [], # Array of strings
      :max_count_per_search => 100
    }

    @config = default_config.merge(config)

    # Setup the client
    consumer_key(@config[:auth][:consumer_key])
    consumer_secret(@config[:auth][:consumer_secret])
    token(@config[:auth][:token])
    secret(@config[:auth][:secret])

    no_update

    @bird_food_stats = {
      :starrable => 0,
      :clonable => 0,
      :retweetable => 0,
      :followable => 0
    }

    setup_exclusions(@config[:exclude])

    @myself = client.user.handle
    @parse_klass = "People" + "_#{@myself}" 

    Parse.init :application_id => config[:parse][:application_id],
               :api_key        => config[:parse][:api_key]    

    # Numerical limits on outgoing actions
    @limits = {
      :run => {
        :follow => with_x_percentage_additional_random(10, 30),
        :star => with_x_percentage_additional_random(150, 50),
        :clone => with_x_percentage_additional_random(100, 50),
        :retweet => with_x_percentage_additional_random(50, 50)
      },
      :actuals => {
        :follow => 0,
        :star => 0,
        :clone => 0,
        :retweet => 0
      }
    }

  end




  # Searches and then eats the infested tweets/users
  # array_of_keywords => [["foo", "bar"]]
  # search_operator => "AND" || "OR"
  # Returns the bird_feed which was processed - for any further follow ups
  def feast_on_keywords(array_of_keywords, operations = nil, search_operator = "AND", mode = :real)
    puts "Mode : #{mode}"
    operations = {:starrable => true, :retweetable => true, :clonable => true, :followable => true} if operations == nil
    bird_feed = {}

    array_of_keywords.shuffle.each { |keywords| # ["foo", "bar"]
      bird_feed.merge! search_tweets(keywords, operations, search_operator, {:include_images => true})  # Find tweets with images
      bird_feed.merge! search_tweets(keywords, operations, search_operator, {:exclude_links => true}) # Find tweets without links
    }

    log("=================================================================", "STARTING OPERATIONS")

    best_bird_feed = select_best_bird_food(bird_feed)
    publish_stats(best_bird_feed)
    process_bird_feed(best_bird_feed, mode)

    # Return back all of the bird food to the caller for further processing
    return best_bird_feed
  end



  # Does the final outbound processing on bird_feed
  # bird_feed => hash {tweet_id => BirdFood}
  def process_bird_feed(bird_feed, mode)
    # Process all bird food and call their related methods
    length = bird_feed.keys.length

    # Ensure that all outbound actions are shuffled before they are acted upon
    all_tweed_ids = bird_feed.keys.shuffle

    index = 0
    all_tweed_ids.each { |tweet_id|
      food_item = bird_feed[tweet_id]
      puts "-------------------------------------------------------------------"
      food_item.get_primary_operations.each { |operation|
        log "Processing [#{index}/#{length}] tweet_id=#{tweet_id} for #{food_item.get_primary_operations.to_json}"        
        if operation == :follow
          self.send(operation, food_item.stuff.user, false, mode) # TODO : flip to true
        else
          self.send(operation, food_item.stuff, mode)
        end
      }  # each

      index += 1
    }
  end



  # Publish stats about the bird feed which is going to be acted upon. How many clones/RT/star/follow
  def publish_stats(bird_feed)
    stats = {:follow => 0, :star => 0, :clone => 0, :retweet => 0}
    bird_feed.each {|tweet_id, bird_food|
      bird_food.get_primary_operations.each { |operation|
        stats[operation] += 1
      }
    }

    log(stats.to_json, "#{@config[:name]} : stats")
  end



  # Tries to filter the entire list of bird_food and picks out the best
  # Removes any users/tweets which give more than 1x exposure to a given user
  # bird_feed = {tweet_id => BirdFood, ...}
  # Returns the cleaned up bird_feed back
  def select_best_bird_food(bird_feed)
    original_feed_length = bird_feed.keys.length
    log "Sanitizing all of the bird_feed, input : #{original_feed_length} tweets"

    # Group by the user handle to know how many unique handles we have...
    # => {user_handle : [[tweet_id, BirdFood], [tweet_id, BirdFood], ...], ...}
    bird_feed_grouped_by_handle = bird_feed.group_by {|tweet_id, bird_food| bird_food.user_handle}

    # Delete all tweets from users who we selected for >1x exposure
    dirty_tweet_ids = []
    multi_tweet_handles = 0
    bird_feed_grouped_by_handle.each { |user_handle, objects|
      if objects.length > 1
        multi_tweet_handles += 1
        objects.each {|o|
          dirty_tweet_ids << o.first # Tweet id
        }
      end
    }

    dirty_tweet_ids.each { 
      |tweet_id| bird_feed.delete(tweet_id)
    }

    log "Sanitized : Tweets removed : #{original_feed_length - bird_feed.keys.length} [#{bird_feed.keys.length} left], \
         User handles removed : #{multi_tweet_handles}"
    return bird_feed
  end



  # NOTE - Actually does the stars
  def star(tweet, mode = :real)
    return false if check_hit?(:tweet_infested, tweet.id, :verbose) == true
    return false if is_bird_feed_usage_in_limit?(:star) == false

    #log("Starring tweet (id=>#{tweet.id}) : [#{tweet.user.handle}] : #{tweet.text}")
    log(tweet, "STAR")
    return if mode == :preview

    save(@parse_klass, 
          {:handle => tweet.user.handle, :mentioned => false, :followed => false, :starred => true})
    record_hit(:tweet_infested, tweet.id)

    rate_limit(:star) { client.favorite(tweet.id) }
    increment_bird_feed_usage(:star)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION) # We don't need to sleep so long after starring
  end



  # NOTE - Actually does the retweet
  def retweet(tweet, mode = :real)
    return false if check_hit?(:tweet_infested, tweet.id, :verbose) == true
    return false if is_bird_feed_usage_in_limit?(:retweet) == false

    #log("Retweeting tweet (id=>#{tweet.id}) : [#{tweet.user.handle}] : #{tweet.text}")
    log(tweet, "RETWEET")
    return if mode == :preview

    record_hit(:tweet_infested, tweet.id)

    rate_limit(:retweet) { client.retweet(tweet.id) }
    increment_bird_feed_usage(:retweet)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION_BASE)
  end



  # NOTE - Actually does the clone
  def clone(tweet, mode = :real)
    return false if check_hit?(:tweet_infested, tweet.id, :verbose) == true
    return false if is_bird_feed_usage_in_limit?(:clone) == false

    clone_text = tweet.text
    # Attribute the tweet to an end user only if it already has a @mention. 100% clone it otherwise
    clone_text = "#{tweet.text} via .@#{tweet.user.handle}" if tweet.text.index("@") != nil
    clone_text = tweet.text if clone_text.length > 140 # revert back to original text if new length with "via .@foo" > 140
    
    #log("Cloning tweet (id=>#{tweet.id}) : [#{tweet.user.handle}] : #{clone_text}")
    log(tweet, "CLONE")
    return if mode == :preview

    record_hit(:tweet_infested, tweet.id)

    rate_limit(:clone) { client.update(clone_text) }
    increment_bird_feed_usage(:clone)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION_BASE)
  end   



  # NOTE - Actually does the tweet with given media file
  # tweet => {:text => "text", :media_path => "/some/file/path"}
  def tweet_with_media(tweet, sleep_multiplier = 10, mode = :real)
    log(tweet, "tweet_with_media")
    return if mode == :preview
     
    rate_limit(:tweet_with_media) { 
      tweet[:media_path].nil? ? client.update(tweet[:text]) : client.update_with_media(tweet[:text], File.new(tweet[:media_path])) 
    }
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION*sleep_multiplier)
  end 



  # NOTE - Actually does the follow
  def follow(user, do_save = true, mode = :real)
    log(user, "follow")
    return if mode == :preview
    return false if is_bird_feed_usage_in_limit?(:follow) == false

    save(@parse_klass, 
          {:handle => user.handle, :mentioned => false, :followed => true, :starred => false}) if do_save == true
    record_hit(:followed, user.handle)

    rate_limit(:follow) { client.follow(user.handle) }
    increment_bird_feed_usage(:follow)
    random_sleep(SLEEP_AFTER_ACTION, 1, SLEEP_AFTER_ACTION_BASE)
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

    user = find(@parse_klass, {
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
      save(@parse_klass, {:mentioned => true, :followed => true, :handle => user["handle"]})
    }

    random_sleep(SLEEP_AFTER_SHOUTOUT, 1, SLEEP_AFTER_SHOUTOUT)
  end



  # Returns the BirdFood of the tweet if the tweet is of interest. 
  # It's corresponding operations of interest are setup as well
  # Nil otherwise
  # Order of interest => (star > retweetable > clonable) || followable
  def process_tweet_for_any_interest(tweet, operations)
    food_item_ops = {}
    counter = 0
    if is_tweet_of_basic_interest?(tweet) == true
      rate_limit(:search_tweets__process_tweet_for_any_interest) {
        # The order of checks govern the needed order
        # Tweet once processed, will never be processed again
        if operations[:starrable] == true and is_starrable?(tweet) == true
          food_item_ops[:starrable] = true
          counter += 1
          @bird_food_stats[:starrable] += 1
        end

        if operations[:retweetable] == true and is_retweetable?(tweet) == true
          food_item_ops[:retweetable] = true
          counter += 1 
          @bird_food_stats[:retweetable] += 1
        end

        if operations[:clonable] == true and is_clonable?(tweet) == true
          food_item_ops[:clonable] = true
          counter += 1 
          @bird_food_stats[:clonable] += 1
        end

        if operations[:followable] == true and is_followable?(tweet.user) == true
          food_item_ops[:followable] = true
          counter += 1 
          @bird_food_stats[:followable] += 1
        end
      } # rate limit
    end    

    return counter > 0 ? BirdFood.new(tweet, food_item_ops, tweet.user.handle) : nil
  end



  # Search based on an array of given keywords
  # operations => {:starrable => true, :retweetable => true, :clonable => true, :followable => true}
  # Randomly, tries to find tweets which are only text status (no link)
  # Returns an array of BirdFood
  def search_tweets(keywords, operations, search_operator = "AND", micro_options = {:include_images => true, :exclude_links => false})
    all_bird_food = {}
    search_text = keywords.length > 1 ? keywords.join(" #{search_operator} ") : keywords.first
    search_text += " filter:images" if micro_options[:include_images] == true
    search_text += " -http" if micro_options[:exclude_links] == true
    search_text += " -I -am -we -me -my -our"

    puts "\n======================================================"
    puts "Searching for #{search_text}"

    original_search_count = 0
    rate_limit(:search) {
      search(search_text, {:lang => @config[:lang], :result_type => "recent"}) do |tweet| 
        original_search_count += 1
        #log(tweet, "TWEET")
        bird_food_item = process_tweet_for_any_interest(tweet, operations)
        all_bird_food[tweet.id] = bird_food_item if bird_food_item != nil

        break if original_search_count >= @config[:max_count_per_search] # Don't search more than what's requested
      end
    }

    puts "\nOriginal search count : #{original_search_count}, infestable : #{all_bird_food.keys.length}"
    puts @bird_food_stats.to_json
    return all_bird_food
  end  




  # TODO - relook into this
  def setup_exclusions(custom_exclude_list = [])
    default_exclusion = ["money", "spammer", "junk", "spam", "fuck", "pussy", "ass", 
                          "shit", "piss", "cunt", "mofo", "cock", "tits", "wife", "sex", "porn",
                          "thanks", "I ", "am", "gun", "wound", "we", "my", "our", "am", "me",
                          "buy", "deal", "follower"]
    @exclude_list = default_exclusion + custom_exclude_list
    exclude(@exclude_list)
  end



  # Figure out which tweet to infest on
  # TODO - how do we check if this is not a dup interaction on the user?
  # mode => :search || :live
  def is_tweet_of_basic_interest?(tweet, mode = :search)
    # Don't process the tweet if we have already infested it before
    return false if check_hit?(:tweet_infested, tweet.id) == true

    # Exclude the tweet if it has lots of hashtags or @ mentions
    return false if tweet.text.count("#") > 3
    return false if tweet.text.count("@") >= 3

    score = 0
    if mode == :search
      score += 1 if tweet.retweet_count >= @config[:tweet][:min_retweet_count] 
      score += 1 if tweet.favorite_count >= @config[:tweet][:min_star_count] 
      return score > 1 ? true : false
    end

    # Only if the tweet has a url AND (is either a via tweet or is not a mention)
    if mode == :live
      if tweet.urls? == true # and is_no_mention_or_via_mention_tweet?(tweet) == true
        return true
      end
    end

    # default
    return false
  end  


  # Is the tweet like "<foo_text> {via||by} @zoo_user"
  def is_no_mention_or_via_mention_tweet?(tweet)
    return true if tweet.user_mentions? == false

    text = tweet.text.downcase
    via_pos = text.index(" via ") || text.index(" by ") || 10000

    return true if via_pos < (text.index(" @") || 10001)
    return false # default
  end



  # Create enough randomness so that every tweet should not become infestable
  def is_randomly_infestable_tweet?(tweet, divide_by = 2)
    return tweet.id % divide_by == 0 ? true : false
  end



  # If tweet is worthy of a star
  # mode => :search || :live
  def is_starrable?(tweet, mode = :search)
    if mode == :search
      # Min star count
      if tweet.favorite_count >= @config[:tweet][:min_star_count]
        return true
      end
    end

    if mode == :live
      # Should not be a mention
      if tweet.user_mentions? == false \
          and is_randomly_infestable_tweet?(tweet) == true
        return true
      end
    end      
  
    # default
    return false
  end


  # If tweet is worthy of being retweeted
  # mode => :search || :live
  def is_retweetable?(tweet, mode = :search)
    if mode == :search
      # Not a reply, min retweet count, moderate star count
      if ((tweet.favorite_count >= @config[:tweet][:moderate_star_count] \
                and tweet.retweet_count >= @config[:tweet][:min_retweet_count]  \
                and tweet.reply? == false)) \
            or (is_followable?(tweet.user) == true)
        return true
      end
    end

    if mode == :live
      # Should have media
      # Should not have user mentions
      if tweet.media? == true \
          and tweet.user_mentions? == false \
          and is_randomly_infestable_tweet?(tweet) == true
        return true
      end
    end    

    # default
    return false
  end


  # If tweet is worthy of being clonable (copy=>paste basically)
  # mode => :search || :live
  def is_clonable?(tweet, mode = :search)
    if mode == :search
      # Not a reply, Min star count, High retweet count
      if (tweet.favorite_count >= @config[:tweet][:min_star_count] \
            and tweet.retweet_count >= @config[:tweet][:moderate_retweet_count]  \
            and tweet.reply? == false)
        return true
      end
    end

    if mode == :live
      # Should have media
      # Should be either no mention or a via mention
      if tweet.media? == true \
          and is_no_mention_or_via_mention_tweet?(tweet) == true \
          and is_randomly_infestable_tweet?(tweet) == true
        return true
      end
    end

    # default
    return false
  end


  # If the user who tweeted the tweet is followable
  def is_followable?(user, mode = :live)
    return false if user.following? == true

    # Friend to following ratio, stars, tweet count, min followers, since on twitter
    # Should not be following the user already
    followers_count = user.followers_count
    friends_count = user.friends_count
    stars_count = user.favorites_count
    tweets_count = user.tweets_count
    account_age = 0 # TODO

    return false if followers_count > 20*1000  # Anyone with more than 50,000 followers is practically a company/celebrity

    followers_to_friends_ratio = (friends_count != 0 ? (followers_count/friends_count).to_f : 0)
    friends_to_followers_ratio = 1/followers_to_friends_ratio.to_f

    return false if friends_to_followers_ratio < 0.2 # Anyone who is not following back is practially a company/celebrity

    if followers_to_friends_ratio >= @config[:user][:followers_to_friends_ratio]  \
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



  # Increment the :actuals values in @limits
  def increment_bird_feed_usage(klass = nil)
    raise if klass == nil
    @limits[:actuals][klass] += 1
    log(@limits[:actuals], "#{@config[:name]} : USAGE STATS")
  end


  # Checks to see if we are not crossing out bird feed consumption usage
  # Returns false if yes, true if within limits
  def is_bird_feed_usage_in_limit?(klass = nil)
    raise if klass == nil
    return @limits[:run][klass] >= @limits[:actuals][klass]
  end


end




# Class which generates real high quality tweets
class LisaTheEliteTweetMaker
  include LisaToolbox

  # config => {:handle => "makuchaku"}
  def initialize(config = nil)
    @config = config
    raise if @config.nil?

    @myself = @config[:myself]

    @lisa = LisaTheBirdie.new(config)
  end



  # search_keyword_cloud => array of array of keywords
  def make_elite_tweets_for_keyword_cloud(search_keyword_cloud, sleep_multiplier = 10)
    search_keyword_cloud.shuffle.each { |search_keywords|
      log("Finding an elite tweet for #{search_keywords}")
      tweet = make_elite_tweet_for(search_keywords)
      @lisa.tweet_with_media(tweet, sleep_multiplier) if not tweet.nil?
    }
  end



  # Make an elite tweet loaded with url & a media
  # search_query => array of keywords
  # Each array is used for making one tweet
  def make_elite_tweet_for(search_query)
    base_media_path = "./media/tmp/"
    elite_tweet = find_news(search_query)

    # If news is not returning anything, sleep for enough time for a news item to be generated
    if elite_tweet == nil
      puts "Could not find any news item for elite tweet"
      #random_sleep(SLEEP_GENERIC, 1, SLEEP_GENERIC*10)
      return nil
    end

    unescaped_tweet_text = add_hashtags(CGI.unescapeHTML(elite_tweet[:item][:title]), search_query)
    short_url = Googl.shorten(elite_tweet[:item][:url]).short_url
    tweet_text = "#{unescaped_tweet_text}  #{short_url}"
    media_uri_md5 = nil

    #puts tweet_text, elite_tweet[:media_uri]

    tweet = {:text => tweet_text, :media_path => nil}
    if not elite_tweet[:media_uri].nil?
      media_uri_md5 = Digest::MD5.hexdigest(elite_tweet[:media_uri])
      download_url(elite_tweet[:media_uri], media_uri_md5)
      tweet[:media_path] = "#{base_media_path}#{media_uri_md5}"
    end

    return tweet
  end


  private


  # For a given search query, returns the first unique news item
  def find_news(search_query)
    klass = "lisaTheEliteTweeter_#{@myself}"

    response = RubyWebSearch::Google.search(:type => :news, :query => search_query.join(" "), :size => 100)
    response.results.each { |item|
      if check_hit?(klass, item[:url]) == false and item[:language] == 'en'
        record_hit(klass, item[:url])
        return {:item => item, :media_uri => find_media(item[:title])} 
      end
    }

    return nil
  end


  # For a given tweet title, returns the first available google image 
  def find_media(tweet_text)
    puts "Finding image for : #{tweet_text}"
    possible_media = GoogleImageSearch.new.search(tweet_text)
    return possible_media if possible_media.nil?

    possible_media.each { |media|
      print "X"
      log(media[:url], "MEDIA") if media[:width] >= 200
      return media[:url] if media[:width] >= 200
    }
    puts CGI.escape(tweet_text)
    return nil
  end



  # Given a text, if search keywords exist in it, make the hashtags
  def add_hashtags(text, search_keywords)
    search_keywords.each { |keyword|
      text.gsub!(/#{keyword}/i, "##{keyword}")
    }
    return text
  end

end





# Checks the conversations in realtime
class LisaTheConversantBird
  include LisaToolbox

  def initialize(config_params = nil)
    raise if config_params.nil? or config_params[:deliver_conversations_to].nil?

    @config = config_params
    @lisa = LisaTheBirdie.new(@config)
    @conversations = {} # {tweet_id => {}, ...}
    @myself = @lisa.client.user.handle
  end


  # Starts watching conversations for a given keyword set
  # keyword_set => [["a", "b"], ...]
  def start_watching_conversations(keyword_set)
    keyword_set.each { |keywords|
      search_text = keywords.join(" AND ") + " filter:replies -RT -#{@myself}"
      
      # Search
      rate_limit(:start_watching_conversations__search) {
        puts search_text
        original_search_count = 0
        @lisa.search(search_text, {:lang => "en", :result_type => "recent"}) do |tweet| 
          log tweet.text, "tweet"
          parent_tweet = find_first_parent_tweet(tweet.id)          
          #log parent_tweet.text, "parent" if not parent_tweet.nil?
          if not parent_tweet.nil? \
            and @conversations[parent_tweet.id] == nil \
            and is_conversation_worth_watching?(tweet, parent_tweet, keywords) == true
              @conversations[parent_tweet.id] = {:parent_tweet => parent_tweet, 
                                                      :search_result_tweet => tweet, 
                                                      :search_keywords => keywords}
          end # if

          original_search_count += 1
          break if original_search_count >= @config[:max_count_per_search]
        end # search
      } # rate_limit

    } # each

    deliver_conversations(@conversations)
    return @conversations
  end



  # As the method says, does all the needed checks
  def is_conversation_worth_watching?(tweet, parent_tweet, keywords)
    false_result = false

    # Don't process any further if the parent_tweet.id conversation is already delivered
    return false_result if check_hit?(:conversations, parent_tweet.id) == true

    rate_limit(:is_conversation_worth_watching) {
      # We found a non-conversation
      return false_result if parent_tweet.nil? or tweet.id == parent_tweet.id
      puts "parent found"

      # Someone is thanking the original tweeter - we don't want these tweets
      return false_result if tweet.text.downcase.index("thank") != nil
      puts "Not thanks"

      # The parent tweet does not has any keywords of interest
      keyword_match_count = 0
      keywords.each {|keyword|
        keyword_match_count += 1 if parent_tweet.text.downcase.index(keyword.downcase) != nil
      }
      return false_result if keyword_match_count < 1 # ensure that atleast one keyword was found in the parent tweet
      puts "keyword found in parent"

      # Child tweet is almost the same as parent tweet
      return false_result if (tweet.text.split(" ") - parent_tweet.text.split(" ")).length < 5
      puts "parent != child"

      # More than 3 hashtags? The original tweet might be an ad
      return false_result if parent_tweet.hashtags.length > 3
      puts "hashtags are ok"

      #return false_result if @lisa.is_followable?(parent_tweet.user) == false
      #puts "Parent is folowable\n\n"

      puts "All OK"
      return true
    }

    return false_result
  end


  # Given a tweet_id, find it's parent tweet recursively. Else, return the tweet OR nil
  def find_first_parent_tweet(tweet_id)
    rate_limit(:find_first_parent_tweet) {
      begin
        tweet = @lisa.client.status(tweet_id)
        puts "[#{tweet.uri}, R?=#{tweet.reply?}] #{tweet.text}"
        return (not tweet.nil? and tweet.reply? == true) ? find_first_parent_tweet(tweet.in_reply_to_status_id) : tweet    
      rescue
        return nil
      end
    }
  end


  # Emails the conversations
  def deliver_conversations(conversations)
    # Record all outgoing conversations
    conversations.keys.each { |tweet_id|
      record_hit(:conversations, tweet_id)
    }

    mail("hello@yobitch.me", @config[:deliver_conversations_to], 
          "Important conversations to engage with on Twitter", conversations.to_json)
  end

end






