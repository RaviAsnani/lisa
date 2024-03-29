#!/usr/bin/env ruby

require "./lisa_the_birdie"

$auth = {
  :consumer_key => '4e01CjniCAD5Tvmvbuw0chAiL',
  :consumer_secret =>'qwLU6Wbk6hz52KuSdrwqkLOlj72LRq12pkxOVcOiWu5rBrkkTR',
  :token =>'99530011-Iivab3OCgzFrl2nu7b0Pj5J8z93QbxIGL2cSOlCnV',
  :secret => 'imR8GB9dKYBMg9nVja6tEPaCUAQOb280R1HlRSvBKMMPo'
}

$parse_auth = {
  :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
  :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
}



def engage_by_elite_tweets
  elite_lisa = LisaTheEliteTweetMaker.new({
    :auth => $auth,
    :parse => $parse_auth,
    :myself => "all_things_modi"
  })

  LisaToolbox.looper do 
    elite_lisa.make_elite_tweets_for_keyword_cloud(
        [
          ["BJP", "narendramodi"], ["indian", "politics"], 
          ["arunjaitley"], ["SushmaSwaraj"], ["Amit", "Shah"], 
          ["SushilModi"], ["drharshvardhan"], ["smritiirani"], ["PrimeMinister", "india"],
          ["RahulGandhi"], ["LokSabha"], ["NDA", "politics"]
        ],
      10)
  end
end



def engage_by_search
  # Engage for ST, F, RT, Clone
  lisa2 = LisaTheBirdie.new({
      :auth => $auth,
      :parse => $parse_auth,
      :exclude => ["yobitchme", "Easy_Branches", "RachelMajor2000", 
                    "gamedev", "indiedev", "Audiograbber", "buy", "deal", "biz"],
      :lang => "en", 
      :tweet => {
        :min_retweet_count => 1, 
        :min_star_count => 1,
        :moderate_retweet_count => 2,
        :moderate_star_count => 2,  
        :high_retweet_count => 3,
        :high_star_count => 3   # To get more starrable tweets into the honeypot :)
      }      
    })

  LisaToolbox.looper do
    lisa2.rate_limit(:looper_internal) {
      puts "\n\n=================Engage for ST, F, RT, Clone===================="
      keywords = [
                  ["#BJP", "#narendramodi"], ["#indian", "#politics"], 
                  ["#arunjaitley"], ["#SushmaSwaraj"], ["#AmitShahOffice"], 
                  ["#naqvimukhtar"], ["#SushilModi"], ["#drharshvardhan"], ["#smritiirani"], ["#PrimeMinister", "#india"],
                  ["#RahulGandhi"], ["#LokSabha"], ["#NDA", "#politics"]
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
  lisa.start_chatting_with_friends_of(["MASTERCHEFonFOX", "BBC_TopGear"])
end



# Runs all engagement modes in different threads
def engage
  threads = []
  #threads << LisaToolbox.run_in_new_thread(:engage_by_elite_tweets) {engage_by_elite_tweets}
  threads << LisaToolbox.run_in_new_thread(:engage_by_search) {engage_by_search}
  #threads << LisaToolbox.run_in_new_thread(:engage_by_realtime) {engage_by_realtime}
  threads.each { |thread| thread.join }
end


# Main execution starts here
engage


