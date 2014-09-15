#!/usr/bin/env ruby

require "./lisa_the_birdie"

$auth = {
  :consumer_key => 'LAoOnbUuWMi5owhaYb9M9qbaA',
  :consumer_secret =>'3oIJehIoXgqS50dMzh5yCdReFKjiWv06Q0k5neKuLhGb8fpt6x',
  :token =>'2330638885-n3pXeokQVuFTsM0YTymGX9L1JBYbn0JaYpam4qY',
  :secret => 'XiiMVK9gyfMcu0u2FVGe7okHKC4rUC7L8pKO2VzISGvl8'
}

$parse_auth = {
  :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
  :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
}



def engage_by_elite_tweets
  LisaToolbox.looper do
    elite_lisa = LisaTheEliteTweetMaker.new({
      :auth => $auth,
      :parse => $parse_auth,
      :myself => "filmmyshaadi",
      :name => "Lisa Elite"
    })
 
    elite_lisa.make_elite_tweets_for_keyword_cloud(
        [
          ['indian', 'wedding'], ['wedding'], ['wedding', 'dress'], ['wedding', 'video'],
          ['wedding', 'planner'], ['weddng', 'photography'], ['wedding', 'ring'], ['bride'],
          ['groom'], ['indian', 'shaadi'], ['wedding', 'film'], ['wedding', 'gurgaon'],
          ['wedding', 'videography'], 
          ['canon', 'photography'], ['canon', 'video'], ['canon', 'dslr'], ['canon', 'lens'],
          ['nikon', 'photography'], ['nikon', 'video'], ['nikon', 'dslr'], ['nikon', 'lens'],
          ['wedding', 'ideas'], ['wedding', 'planing'], ['wedding', 'planner'], ['wedding', 'destination'],
          ['wedding', 'honeymoon'], ['wedding', 'photos'], ['wedding', 'fashion'], 
          ['wedding', 'service'], ['wedding', 'live'], ['wedding', 'inspiration'], ['wedding', 'cake'],
          ['wedding', 'blog'], ['wedding', 'tips'], ['wedding', 'makeup'], ['wedding', 'gift'],
          ['wedding', 'reception']
        ])
  end

end



def engage_by_search
  exclude_keywords = ["packages", "filmmyshaadi", "Easy_Branches", "RachelMajor2000", 
                    "gamedev", "indiedev", "Audiograbber", "buy", "deal", "biz", "follower", "buymonthlyfollowers"]
  
  LisaToolbox.looper do

    # Engage for ST, F, RT, Clone
    lisa2 = LisaTheBirdie.new({
        :name => "Lisa Search",
        :auth => $auth,
        :parse => $parse_auth,
        :exclude => exclude_keywords,
        :lang => "en", 
        :tweet => {
          :min_retweet_count => 1, 
          :min_star_count => 1,
          :moderate_retweet_count => 1,
          :moderate_star_count => 1,  
          :high_retweet_count => 2,
          :high_star_count => 2   # To get more starrable tweets into the honeypot :)
        },
        :user => {
          :followers_to_friends_ratio => 0.1,
          :min_followers_count => 100,
          :min_star_count => 10,
          :min_tweet_count => 300,
          :account_age => 0
        },
        :max_count_per_search => 1000   
      })

  
    puts "\n\n=================Engage for ST, F, RT, Clone===================="
    keywords = [
                  ['#indian', '#wedding'], ['#wedding'], ['#wedding', '#dress'], ['#wedding', '#video'],
                  ['#wedding', '#planner'], ['#weddng', '#photography'], ['#wedding', '#ring'], ['#bride'],
                  ['#groom'], ['#indian', '#shaadi'], ['#wedding', '#film'], ['#wedding', '#gurgaon'],
                  ['#wedding', '#videography'],
                  ['#canon', '#photography'], ['#canon', '#video'], ['#canon', '#dslr'], ['#canon', '#lens'],
                  ['#nikon', '#photography'], ['#nikon', '#video'], ['#nikon', '#dslr'], ['#nikon', '#lens'],
                  ['#wedding', '#ideas'], ['#wedding', '#planing'], ['#wedding', '#planner'], ['#wedding', '#destination'],
                  ['#wedding', '#honeymoon'], ['#wedding', '#photos'], ['#wedding', '#fashion'],
                  ['#wedding', '#service'], ['#wedding', '#live'], ['#wedding', '#inspiration'], ['#wedding', '#cake'],
                  ['#wedding', '#blog'], ['#wedding', '#tips'], ['#wedding', '#makeup'], ['#wedding', '#gift'],
                  ['#wedding', '#reception']
               ]
    lisa2.feast_on_keywords(keywords, 
                              {:starrable => true, :retweetable => true, :clonable => true, :followable => true},
                              "AND")

  end
end



def engage_by_realtime
  lisa = LisaTheChattyBird.new({
      :auth => $auth,
      :name => "Lisa Realtime"
    })

  #lisa.start_chatting
  lisa.start_chatting_with_friends_of(["sue_bryce"])
end



# Runs all engagement modes in different threads
def engage
  threads = []
  threads << LisaToolbox.run_in_new_thread(:engage_by_elite_tweets) {engage_by_elite_tweets}
  threads << LisaToolbox.run_in_new_thread(:engage_by_search) {engage_by_search}
  threads << LisaToolbox.run_in_new_thread(:engage_by_realtime) {engage_by_realtime}
  threads.each { |thread| thread.join }
end


# Main execution starts here
engage


