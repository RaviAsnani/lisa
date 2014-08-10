require "lisa_the_birdie"


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
      :high_star_count => 0   # To get more starrable tweets into the honeypot :)
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
  lisa2 = LisaTheBirdie.new

  lisa2.rate_limit(:looper_internal) {
    puts "\n\n=================RUN 2===================="
    keywords = ['#ruby', '#marketing', '#anroid', '#growthhacking', 
                '#apps', '#android', '#ios', 'ruboto', '#indiedev', '#startup', '#startups', 
                '#cloud', '#analytics', '#itunes', '#googleplay', '#facebook', '#apple', '#tech',
                '#social', '#product']
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


