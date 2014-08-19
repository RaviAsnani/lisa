#!/usr/bin/env ruby

require "./lisa_the_birdie"


LisaToolbox.looper do 

  # # Main execution starts here
  # lisa1 = LisaTheBirdie.new({
  #   :auth => {
  #     :consumer_key => 'fl8Xb0Lv6CkKdbNAMGB8mBUrG',
  #     :consumer_secret =>'mAtdDResuDJp9xwsInihXD5rcDpMEnJ4nMRtOGtcNSH0agbZ28',
  #     :token =>'2592724712-o8gSOnGMuwUfaXcB1nGR1hrUIk9YkSDrBX108Fx',
  #     :secret => 'Qw8AQGMR1K2HAWfZ6GkACLOG66I6UdVIYF9iQcdHUQKgA'
  #   },
  #     :parse => {
  #       :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
  #       :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
  #     },  
  #   :exclude => ["yobitchme", "Easy_Branches"],
  #   :lang => "en", 
  #   :tweet => {
  #     :min_retweet_count => 0, 
  #     :min_star_count => 0,
  #     :moderate_retweet_count => 2,
  #     :moderate_star_count => 2,  
  #     :high_retweet_count => 4,
  #     :high_star_count => 0   # To get more starrable tweets into the honeypot :)
  #   },
  #   :user => {
  #     :followers_to_friends_ratio => 0.1,
  #     :min_followers_count => 100,
  #     :min_star_count => 25,
  #     :min_tweet_count => 100,
  #     :account_age => 0
  #   }
  # })

  # lisa1.rate_limit(:looper_internal) {
  #   puts "=================RUN 1===================="
  #   keywords = ['bitching', 'bitch']    
  #   interesting_stuff = lisa1.search_tweets(keywords, {:starrable => true})
  #   puts interesting_stuff
  #   puts "\n\n=============starrable================"
  #   lisa1.star(interesting_stuff[:starrable])
  # }



  # Main execution starts here
  lisa2 = LisaTheBirdie.new({
      :auth => {
        :consumer_key => 'fl8Xb0Lv6CkKdbNAMGB8mBUrG',
        :consumer_secret =>'mAtdDResuDJp9xwsInihXD5rcDpMEnJ4nMRtOGtcNSH0agbZ28',
        :token =>'2592724712-o8gSOnGMuwUfaXcB1nGR1hrUIk9YkSDrBX108Fx',
        :secret => 'Qw8AQGMR1K2HAWfZ6GkACLOG66I6UdVIYF9iQcdHUQKgA'
      },
      :parse => {
        :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
        :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
      },
      :exclude => ["yobitchme", "Easy_Branches", "RachelMajor2000", 
                    "gamedev", "indiedev", "Audiograbber", "buy", "deal"],
      :lang => "en", 
      :tweet => {
        :min_retweet_count => 1, 
        :min_star_count => 1,
        :moderate_retweet_count => 2,
        :moderate_star_count => 2,  
        :high_retweet_count => 5,
        :high_star_count => 5   # To get more starrable tweets into the honeypot :)
      },
      :user => {
        :followers_to_friends_ratio => 0.3,
        :min_followers_count => 500,
        :min_star_count => 25,
        :min_tweet_count => 1000,
        :account_age => 0
      }      
    })

  lisa2.rate_limit(:looper_internal) {
    puts "\n\n=================RUN 2===================="
    keywords = [
                # ['#ruby', '#marketing', '#anroid'], 
                # ['#growthhacking', '#social', "#idea"],
                # ['#apps', '#android', '#ios', 'ruboto'], 
                # ['#indiedev', '#startup', '#startups'],
                # ['#cloud', '#analytics', '#itunes'], 
                ['#googleplay', '#facebook', '#apple', '#tech'],
                ["android", "ios", "#windows"], 
                ["techcrunch", "ycombinator", "wpcentral"], 
                ["androidandme", "androidcentral", "droid_life"], 
                ["androidpolice", "Phandroid", "androidtapp"]
               ]
    keywords.shuffle.each do |keyword_set|
      lisa2.feast_on_keywords(keyword_set)
    end
  }

end # End looper



