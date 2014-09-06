#!/usr/bin/env ruby

require "./lisa_the_birdie"

$auth = {
  :consumer_key => 'xSk9IoxQbnxKbw0ebjuJ6sV5o',
  :consumer_secret =>'Lyp1xWyReu7kgday1QOR7XN3JMA9OrB7LvBooKs3shciWimqat',
  :token =>'137607844-Gzmkt1zs696XZnX3GpyT7Lba2rT7E6TAIORxA9LU',
  :secret => '29eTALhvojnN3uRRqBTnI8k6Ej1pbDU0XhFjAS9vuui44'
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
      :myself => "ravi_asnani"
    })

  
    elite_lisa.make_elite_tweets_for_keyword_cloud(
        [
          ['food', 'delicious'],
          ['food', 'cook', 'recipe'],
          ['cake', 'recipe'],
          ["italian", "cuisine"],
          ["cuisine"],
          ["celebrity", "chef"],
          ["top", "chef"],
          ["masterchef"],
          ["ferrari"],
          ["bmw"],
          ["honda"],
          ["electric", "cars"],
          ["hybrid", "cars"],
          ["sushi"], ["grilled", "food"], ["salad"], ["johnny", "rockets"], ["lebanese", "food"], ["fat", "lulu"], ["pizza"],
          ["pagani"], ["mclaren"], ["top", "gear"]
        ],
      10)
  end
end



def engage_by_search
  LisaToolbox.looper do
    # Engage for ST, F, RT, Clone
    lisa2 = LisaTheBirdie.new({
        :auth => $auth,
        :parse => $parse_auth,
        :exclude => ["yobitchme", "Easy_Branches", "RachelMajor2000", 
                      "gamedev", "indiedev", "Audiograbber", "buy", "deal", "biz"],
        :lang => "en", 
        :tweet => {
          :min_retweet_count => 2, 
          :min_star_count => 2,
          :moderate_retweet_count => 3,
          :moderate_star_count => 3,  
          :high_retweet_count => 5,
          :high_star_count => 5   # To get more starrable tweets into the honeypot :)
        }      
      })

  
    lisa2.rate_limit(:looper_internal) {
      puts "\n\n=================Engage for ST, F, RT, Clone===================="
      keywords = [
                  ['food', 'delicious'],
                  ['food', 'cook', 'recipe'],
                  ['cake', 'recipe'],
                  ["italian", "cuisine"],
                  ["celebrity", "chef"],
                  ["top", "chef"],
                  ["masterchef"],
                  ["ferrari", "bmw"],
                  ["honda"],
                  ["electric", "cars"],
                  ["hybrid", "cars"],
                  ["grilled", "food"], 
                  ["salad"], 
                  ["pagani"], 
                  ["mclaren"], 
                  ["top", "gear"]
                 ]
      keywords.shuffle.each do |keyword_set|
        lisa2.feast_on_keywords(keyword_set, 
                                {:starrable => true, :retweetable => true, :clonable => true, :followable => false},
                                "AND")
      end
    }
  end
end



def engage_by_realtime
  lisa = LisaTheChattyBird.new({
      :auth => $auth
    })

  #lisa.start_chatting
  lisa.start_chatting_with_friends_of(["MASTERCHEFonFOX", "BBC_TopGear", "fooddotcom", "chefsfeed"])
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


