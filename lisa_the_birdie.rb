#!/usr/bin/env ruby

# https://github.com/muffinista/chatterbot
# http://rdoc.info/gems/twitter/Twitter/REST/Favorites#favorite-instance_method
# https://dev.twitter.com/docs/api/1.1

require 'rubygems'
require 'chatterbot/dsl'
require 'parse-ruby-client'
require "pp"



module LisaOnParse

  # klass => The class name
  # params => {k1=>v1, k2=>v2}
  def save(klass, params)
    puts "Saving in Parse [#{klass}] : #{params.to_json}"
    obj = Parse::Object.new(klass)
    params.each { |key, value|
      obj[key.to_s] = value
    }
    obj.save
    return obj
  end

end



class LisaTheBirdie
  include LisaOnParse

  attr_accessor :interesting_stuff, :config

  SLEEP_AFTER_ACTION = 60 # secs
  APP_URL = "http://j.mp/yo_bitch"
  PARSE_KLASS = "People"

  def initialize(config)
    consumer_key 'fl8Xb0Lv6CkKdbNAMGB8mBUrG'
    consumer_secret 'mAtdDResuDJp9xwsInihXD5rcDpMEnJ4nMRtOGtcNSH0agbZ28'
    secret 'Qw8AQGMR1K2HAWfZ6GkACLOG66I6UdVIYF9iQcdHUQKgA'
    token '2592724712-o8gSOnGMuwUfaXcB1nGR1hrUIk9YkSDrBX108Fx'  

    @config = config

    no_update

    @interesting_stuff = {
      :starrable => [],
      :retweetable => [],
      :clonable => [],
      :users => []
    }    

    setup_exclusions

    Parse.init :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
               :api_key        => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
  end



  # Search based on an array of given keywords
  # operations => {:starrable => true, :retweetable => true, :clonable => true, :followable => true}
  def search_tweets(keywords, operations=nil)
    operations = {:starrable => true, :retweetable => true, :clonable => true, :followable => true} if operations == nil
    search_text = keywords.length > 1 ? keywords.join(" OR ") : keywords.first
    puts "Searching for #{search_text}"

    original_search_count = 0
    rate_limit(:search) {
      search(search_text, :lang => @config[:lang]) do |tweet| 
        original_search_count += 1
        #puts stringify(tweet, :tweet)
        if is_tweet_of_basic_interest?(tweet) == true
          rate_limit(:search_tweets) {
            (@interesting_stuff[:starrable] << tweet if is_starrable?(tweet) == true) if operations[:starrable] == true
            (@interesting_stuff[:retweetable] << tweet if is_retweetable?(tweet) == true) if operations[:retweetable] == true
            (@interesting_stuff[:clonable] << tweet if is_clonable?(tweet) == true) if operations[:clonable] == true
            (@interesting_stuff[:users] << tweet.user if is_followable?(tweet.user) == true) if operations[:followable] == true
          }
        end
      end
    }

    puts "Original search count : #{original_search_count}"
    return @interesting_stuff
  end  



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


  # NOTE - Actually does the stars
  def star(tweets)
    tweets.each { |tweet|
      puts "Starring [#{tweet.id}][#{tweet.user.handle}] : #{tweet.text}"
      rate_limit(:star) { client.favorite(tweet.id) }
      save(PARSE_KLASS, {:handle => tweet.user.handle, :mentioned => false, :followed => false, :starred => true})
      random_sleep
    }
  end


  # NOTE - Actually does the retweet
  def retweet(tweets)
    tweets.each { |tweet|
      puts "Retweet [#{tweet.id}][#{tweet.user.handle}] : #{tweet.text}"
      rate_limit(:retweet) { client.retweet(tweet.id) }
      random_sleep
    }
  end


  # NOTE - Actually does the clone
  def clone(tweets)
    tweets.each { |tweet|
      puts "Clone [#{tweet.id}][#{tweet.user.handle}] : #{tweet.text}"
      rate_limit(:clone) { client.tweet(tweet.text) }
      random_sleep
    }
  end    


  # NOTE - Actually does the follow
  def follow(users)
    users.each { |user|
      puts "Folllowing [#{user.handle}]"
      rate_limit(:follow) { client.follow(user.handle) }
      save(PARSE_KLASS, {:handle => user.handle, :mentioned => false, :followed => true, :starred => false})
      random_sleep
    }
  end



  # Picks up any 3 friends or followers and asks them to try out the app
  def shoutout_friends_followers
    media_files = ["./media/twitter_media1.png", "./media/twitter_media2.png"]
    tweet_templates = [
      "A shoutout to __USER__ : try our Yo! B*tch android app, primed for bitching : #{APP_URL}",
      "__USER__ : would love your feedback on our Yo! B*tch app : #{APP_URL}",
      "__USER__ : what's your take on our Yo! B*tch android app : #{APP_URL}",
      "__USER__ : try our Yo! B*tch android app : #{APP_URL}",
      "Love bitching? __USER__, try our Yo! B*tch android app : #{APP_URL}"
    ]

    media = media_files[rand(media_files.length-1)]
    tweet = tweet_templates[rand(tweet_templates.length-1)]
    rate_limit(:shoutout_friends_followers__update) { 
      client.update_with_media(tweet, File.new(media))
    }
  end



  # Helper method to loop
  def self.looper(&block)
    loop do
      puts "################################################################"
      puts "Starting LisaTheBirdie at #{Time.now}"

      block.call

      puts "Ending LisaTheBirdie at #{Time.now}"
      puts "################################################################"
    end
  end


  # Calls the given block with a sleeping factor of the rate limiting
  # Currently we don't care about the lost activity as we don't redo
  def rate_limit(where, &block)
    begin
      block.call
    rescue Twitter::Error::TooManyRequests => error
      puts "Rate limit engaged in #{where}, sleeping for #{error.rate_limit.reset_in} seconds #############################"
      sleep(error.rate_limit.reset_in)
    rescue Exception => e
      puts "Got generic exception..."
      puts e.backtrace
    end
  end



  private


  def random_sleep
    sleep_for = rand(SLEEP_AFTER_ACTION)
    puts "Randomly sleeping for #{sleep_for} seconds"
    sleep(sleep_for)
  end



  # TODO - relook into this
  def setup_exclusions
    exclude "spammer", "junk", "spam", "fuck", "pussy", "ass", "shit", "piss", "cunt", "mofo", "cock", "tits", "wife", "sex", "porn"
  end



  # Figure out which tweet to infest on
  # TODO - how do we check if this is not a dup interaction on the user?
  def is_tweet_of_basic_interest?(tweet)
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

      # Only star if the tweet is not already starred
      if check_hit?(:tweet_infested, tweet.id) == false
        record_hit(:tweet_infested, tweet.id)
        return true
      else
        puts "Found dup hit in is_starrable? : #{tweet.id} @#{tweet.user.handle} ================================="
      end
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
      
      # Only retweet if the tweet is not already processed
      if check_hit?(:tweet_infested, tweet.id) == false
        record_hit(:tweet_infested, tweet.id)
        return true
      else
        puts "Found dup hit in is_retweetable? : #{tweet.id} @#{tweet.user.handle} ================================="
      end
    end
    return false
  end


  # If tweet is worthy of being clonable (copy=>paste basically)
  def is_clonable?(tweet)
    # Not a reply, High star count, High retweet count
    if (tweet.favorite_count >= @config[:tweet][:moderate_star_count] \
          and tweet.retweet_count >= @config[:tweet][:moderate_retweet_count]  \
          and tweet.reply? == false)
      
      # Only clone if the tweet is not already processed
      if check_hit?(:tweet_infested, tweet.id) == false
        record_hit(:tweet_infested, tweet.id)
        return true
      else
        puts "Found dup hit in is_clonable? : #{tweet.id} @#{tweet.user.handle} ================================="
      end
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
        record_hit(:followed, user.handle)
        return true
      else
        puts "Found dup hit in is_followable? @#{user.handle} ================================="
      end        
    end

    return false
  end



  # klass => :starred, :followed
  # data => actual value to record. Tweet.id in case of starred, user.handle in case of followed
  def record_hit(klass, data)
    system("echo '#{data}' >> #{klass.to_s}.txt")
  end

  def check_hit?(klass, data)
    command = "cat #{klass.to_s}.txt | grep '#{data}'"
    return system(command)
  end

end



LisaTheBirdie.looper do 

  # Main execution starts here
  lisa1 = LisaTheBirdie.new({
    :lang => "en", 
    :tweet => {
      :min_retweet_count => 0, 
      :min_star_count => 0,
      :moderate_retweet_count => 2,
      :moderate_star_count => 2,  
      :high_retweet_count => 4,
      :high_star_count => 0,   # To get more starrable tweets into the honeypot :)
    },
    :user => {
      :followers_to_friends_ratio => 0.1,
      :min_followers_count => 100,
      :min_star_count => 25,
      :min_tweet_count => 100,
      :account_age => 0
    }
  })

  lisa1.rate_limit(:looper_internal) {
    puts "=================RUN 1===================="
    keywords = ['bitching', 'bitch']    
    interesting_stuff = lisa1.search_tweets(keywords, {:starrable => true})
    puts interesting_stuff
    puts "\n\n=============starrable================"
    lisa1.star(interesting_stuff[:starrable])
  }



  # Main execution starts here
  lisa2 = LisaTheBirdie.new({
    :lang => "en", 
    :tweet => {
      :min_retweet_count => 1, 
      :min_star_count => 1,
      :moderate_retweet_count => 2,
      :moderate_star_count => 2,  
      :high_retweet_count => 4,
      :high_star_count => 4,   # To get more starrable tweets into the honeypot :)
    },
    :user => {
      :followers_to_friends_ratio => 0.3,
      :min_followers_count => 250,
      :min_star_count => 25,
      :min_tweet_count => 1000,
      :account_age => 0
    }
  })

  lisa2.rate_limit(:looper_internal) {
    puts "\n\n=================RUN 2===================="
    keywords = ['#ruby', '#marketing', '#anroid', '#growthhacking', 
                '#apps', '#android', '#ios', 'ruboto', '#indiedev', '#startup', '#startups', 
                '#cloud', '#analytics', 'itunes', 'googleplay', 'facebook', 'twitter', 'apple', 'tech']
    interesting_stuff = lisa2.search_tweets(keywords)
    puts interesting_stuff
    puts "\n\n=============starrable================"
    lisa2.star(interesting_stuff[:starrable])
    puts "\n\n=============clonable================"
    lisa2.clone(interesting_stuff[:clonable])
    puts "\n\n=============retweetable================"
    lisa2.retweet(interesting_stuff[:retweetable])        
    puts "\n\n=============users================"
    lisa2.follow(interesting_stuff[:users])
  }

end # End looper







