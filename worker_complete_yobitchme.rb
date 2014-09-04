#!/usr/bin/env ruby

require "./lisa_the_birdie"

$auth = {
  :consumer_key => '07y02Rx3pjpVlAqmwiLZeONBQ',
  :consumer_secret =>'SFN4ennNrCRu8eL7piWRRvJrpupi8IV5dDcN3gnPcms97LlRAt',
  :token =>'2592724712-sATvge1OdeqOd1zpE2riTKpiPaCmn0o3Jarnppe',
  :secret => 'XtH5VQKXVURUDfQ0GPqxrcYO4wGMqdUcLnF26PP0YoVz0'
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
      :myself => "yobitchme",
      :name => "Lisa Elite"
    })
 
    elite_lisa.make_elite_tweets_for_keyword_cloud(
        [
          ["design", "typography"], ["fonts", "typeface"], ["Graphic", "Design", "photoshop"],
          ['android'], ["google", "play"],
          ['marketing', 'seo'], ["MarketingTips"],
          ['growthhacking'],
          ['android', "app"], 
          ['ios', 'itunes'], 
          ["iphone", "jailbreak"],
          ["app", "development"],
          ['startup'], ["Entrepreneur"], ["Venture", "Capital"], ["Crowdfunding"],
          ['cloud', 'analytics'], 
          ["windows", "mobile"], 
          ["ycombinator"], ["Startup", "School"],
          ["funding", "invest"],
          ["social", "media"],
          ["WebsiteDesign"],
          ["WebDevelopment"], 
          ["angularjs"], ["javascript"], ["ubuntu"], ["smartwatch"], ["android", "wear"], ["moto360"], ["IFA2014"],
          ["ruby", "programming"] 
        ])
  end

end



def engage_by_search
  exclude_keywords = ["packages", "yobitchme", "Easy_Branches", "RachelMajor2000", 
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
          :min_retweet_count => 2, 
          :min_star_count => 2,
          :moderate_retweet_count => 3,
          :moderate_star_count => 3,  
          :high_retweet_count => 5,
          :high_star_count => 5   # To get more starrable tweets into the honeypot :)
        }      
      })

  
    puts "\n\n=================Engage for ST, F, RT, Clone===================="
    keywords = [
                  # ["#design", "#typography"], ["#fonts"], ["#typeface"], ["#Design", "#photoshop"],
                  # ['#android'], ["#googleplay"],
                  # ['#marketing', '#seo'], ["#MarketingTips"],
                  ['#growthhacking'],
                  # ['#android', "#app"], 
                  # ['#iphone', '#app'], 
                  # ["#iphone", "#jailbreak"],
                  # ["#app", "#development"],
                  # ['#startup'], ["#Entrepreneur"], ["#Venture", "#Capital"], ["#Crowdfunding", "startup"],
                  # ['#cloud', '#analytics'], 
                  # ["#windows", "#mobile"], ["#winmo"],
                  # ["#ycombinator"], ["#Startup", "#School"],
                  # ["#funding", "#invest"],
                  # ["#social", "#media"],
                  # ["#WebsiteDesign"],
                  # ["#WebDevelopment"],
                  # ["#angularjs"], ["#javascript"], ["#ubuntu"], ["#smartwatch"], 
                  # ["#android", "#wear"], ["#moto360"], ["#IFA2014"],
                  # ["rubyonrails"], ["#backbonejs"], ["#apple", '#swift'], ["#python"], ["#lamp", "#php"]
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
  lisa.start_chatting_with_friends_of(["startupchile", "500Startups", "pjain"])
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


