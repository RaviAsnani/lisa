#!/usr/bin/env ruby

require "./lisa_the_birdie"

$auth = {
  :consumer_key => 'LdU9E9mT4xA8h9sGNifDeW1Fv',
  :consumer_secret =>'tJZbyNDBxwnVXEDVX4I16ElGBiDsyvxDiL9yH5vWuuBuMaYh3Y',
  :token =>'443557785-0y0r3yi4SmYDluVAzZE62mPZvMoSson48jZnKBnS',
  :secret => 'xZ9pt3a4uLalDb1dkGtTvPA0mJKf67gFMYDUDyrc97dWQ'
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
      :myself => "vishne0",
      :name => "Lisa Elite"
    })
 
    elite_lisa.make_elite_tweets_for_keyword_cloud(
        [
          ["linux"], ["ubuntu"], ["debian", "linux"], ["kernel"],
          ["linux", "security"], ["infosec"], ["data", "breach"], ["cyber", "hacking"], 
          ["mobile", "malware"], ["internet", "privacy"],
          ["server", "security"],
          ["black", "metal"], ["death", "metal"], ["doom", "metal"], ["metal", "music"],
          ["startups"], ["Entrepreneur"], ["funding"], ["startup", "incubator"],
          ["sql", "injection"], ["mysql"], ["xss", "attack"], ["appsec"], ["hacking"],
          ["security", "vulnerability"], ["exploit", "security"]
        ])
  end

end



def engage_by_search
  exclude_keywords = ["packages", "vishne0", "Easy_Branches", "RachelMajor2000", 
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
          :moderate_retweet_count => 2,
          :moderate_star_count => 2,  
          :high_retweet_count => 3,
          :high_star_count => 3   # To get more starrable tweets into the honeypot :)
        },
        :user => {
          :followers_to_friends_ratio => 0.3,
          :min_followers_count => 250,
          :min_star_count => 25,
          :min_tweet_count => 1000,
          :account_age => 0
        },
        :max_count_per_search => 300   
      })

  
    puts "\n\n=================Engage for ST, F, RT, Clone===================="
    keywords = [
                ["#linux"], ["#ubuntu"], ["#debian", "#linux"], ["#kernel"],
                ["#linux", "#security"], ["#infosec"], ["#data", "#breach"], ["#cyber", "#hacking"], 
                ["#mobile", "#malware"], ["#internet", "#privacy"],
                ["#server", "#security"],
                ["#black", "#metal"], ["#death", "#metal"], ["#doom", "#metal"], ["#metal", "#music"],
                ["#startups"], ["#Entrepreneur"], ["#funding"], ["#startup", "#incubator"],
                ["#sql", "#injection"], ["#mysql"], ["#xss", "#attack"], ["#appsec"], ["#hacking"],
                ["#security", "#vulnerability"], ["#exploit", "#security"]
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
  lisa.start_chatting_with_friends_of(["CindyMurph", "SANSInstitute", "jameslyne"])
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


