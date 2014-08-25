#!/usr/bin/env ruby

require "./lisa_the_birdie"

$auth = {
  :consumer_key => 'W5Pkpm1bvNEd3vN56dwHguMv6',
  :consumer_secret =>'CSk5CNFpdNkHe8A9Z5ZXfNel8NzW7fFJQ6Zxf7k58LZ1GMrXiE',
  :token =>'2759265168-g6PVAKbsOooVCuy9q1VAXDpSQ9nYgqPAhyDvSP0',
  :secret => 'qtTtqTYRx774QFEqnr7BjctC3aZhLEuo5FfL8rKdf0XrZ'
}

$parse_auth = {
  :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
  :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
}



def engage_by_elite_tweets
  elite_lisa = LisaTheEliteTweetMaker.new({
    :auth => $auth,
    :parse => $parse_auth,
    :myself => "keenu30"
  })

  LisaToolbox.looper do 
    elite_lisa.make_elite_tweets_for_keyword_cloud(
        [
          ["bollywood"], ["movies"], ["srk"], ["star", "plus"], ["colors", "tv"],
          ["salman", "khan"], ["amitabh", "bachhan"], ["indian", "cinema"]
        ],
      10)
  end
end



def engage_by_search
  # Engage for ST, F, RT, Clone
  lisa2 = LisaTheBirdie.new({
      :auth => $auth,
      :parse => $parse_auth,
      :exclude => ["BigBoss_Pree", "JaunceBestfriend"],
      :lang => "en", 
      :tweet => {
        :min_retweet_count => 1, 
        :min_star_count => 1,
        :moderate_retweet_count => 2,
        :moderate_star_count => 2,  
        :high_retweet_count => 4,
        :high_star_count => 4   # To get more starrable tweets into the honeypot :)
      }      
    })

  LisaToolbox.looper do
    lisa2.rate_limit(:looper_internal) {
      puts "\n\n=================Engage for ST, F, RT, Clone===================="
      keywords = [
                  ["bollywood"], ["movies"], ["srk"], ["star", "plus"], ["colors", "tv"], 
                  ["indian", "cinema"]
                 ]
      keywords.shuffle.each do |keyword_set|
        lisa2.feast_on_keywords(keyword_set, {:starrable => true, :retweetable => true, :clonable => true, :followable => false})
      end
    }
  end
end



def engage_by_realtime
  lisa = LisaTheChattyBird.new({
      :auth => $auth
    })

  #lisa.start_chatting
  lisa.start_chatting_with_friends_of(["MASTERCHEFonFOX", "BBC_TopGear"])
end



# Runs all engagement modes in different threads
def engage
  threads = []
  threads << LisaToolbox.run_in_new_thread(:engage_by_elite_tweets) {engage_by_elite_tweets}
  threads << LisaToolbox.run_in_new_thread(:engage_by_search) {engage_by_search}
  #threads << LisaToolbox.run_in_new_thread(:engage_by_realtime) {engage_by_realtime}
  threads.each { |thread| thread.join }
end


# Main execution starts here
engage


