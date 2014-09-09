#!/usr/bin/env ruby

require "./lisa_the_birdie"


#LisaToolbox.looper do 

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





# YB
# $auth = {
#   :consumer_key => '07y02Rx3pjpVlAqmwiLZeONBQ',
#   :consumer_secret =>'SFN4ennNrCRu8eL7piWRRvJrpupi8IV5dDcN3gnPcms97LlRAt',
#   :token =>'2592724712-sATvge1OdeqOd1zpE2riTKpiPaCmn0o3Jarnppe',
#   :secret => 'XtH5VQKXVURUDfQ0GPqxrcYO4wGMqdUcLnF26PP0YoVz0'
# }

# $parse_auth = {
#   :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
#   :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
# }


# RAVI
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

  # # Main execution starts here
  # lisa2 = LisaTheBirdie.new({
  #     :auth => $auth,
  #     :parse => $parse_auth,
  #     :exclude => ["yobitchme", "Easy_Branches", "RachelMajor2000", 
  #                   "gamedev", "indiedev", "Audiograbber", "buy", "deal", "biz"],
  #     :lang => "en", 
  #     :tweet => {
  #       :min_retweet_count => 1, 
  #       :min_star_count => 1,
  #       :moderate_retweet_count => 2,
  #       :moderate_star_count => 2,  
  #       :high_retweet_count => 5,
  #       :high_star_count => 5   # To get more starrable tweets into the honeypot :)
  #     },
  #     :user => {
  #       :followers_to_friends_ratio => 0.7,
  #       :min_followers_count => 1000,
  #       :min_star_count => 25,
  #       :min_tweet_count => 1000,
  #       :account_age => 0
  #     }      
  #   })

  # lisa2.rate_limit(:looper_internal) {
  #   puts "\n\n=================RUN 2===================="
  #   keyword_set = [
  #                   #["#design", "#typography"], ["#fonts"], ["#typeface"], ["#Design", "#photoshop"],
  #                   #['#android'], ["#googleplay"],
  #                   #['#marketing', '#seo'], ["#MarketingTips"],
  #                   #['#growthhacking'],
  #                   #['#android', "#app"], 
  #                   ['#iphone', '#app'], 
  #                   #["#iphone", "#jailbreak"],
  #                   #["#app", "#development"],
  #                   #['#startup'], ["#Entrepreneur"], ["#Venture", "#Capital"], ["#Crowdfunding", "startup"],
  #                   #['#cloud', '#analytics'], 
  #                   #["#windows", "#mobile"], ["#winmo"],
  #                   #["#ycombinator"], ["#Startup", "#School"],
  #                   #["#funding", "#invest"],
  #                   #["#social", "#media"],
  #                   #["#WebsiteDesign"],
  #                   #["#WebDevelopment"],
  #                   #["#angularjs"], ["#javascript"], ["#ubuntu"], ["#smartwatch"], 
  #                   #["#android", "#wear"], ["#moto360"], ["#IFA2014"],
  #                   #["rubyonrails"], ["#backbonejs"], ["#apple", '#swift'], ["#python"], ["#lamp", "#php"],
  #                   #["#startupchile"]
  #                ]
  #   lisa2.feast_on_keywords(keyword_set, 
  #                     {:starrable => true, :retweetable => true, :clonable => true, :followable => true}, 
  #                     "AND", :preview)
  # }

#end # End looper


$lisa_conversation = LisaTheConversantBird.new({
  :auth => $auth,
  :parse => $parse_auth,
  :exclude => ["yobitchme", "Easy_Branches", "RachelMajor2000", 
                "gamedev", "indiedev", "Audiograbber", "buy", "deal", "biz", 'skjain_05'],
  :user => {
    :followers_to_friends_ratio => 0.2,
    :min_followers_count => 200,
    :min_star_count => 25,
    :min_tweet_count => 300,
    :account_age => 0
  },
  :max_count_per_search => 100,
  :max_results_per_search => 2,
  :deliver_conversations_to => "maku@makuchaku.in"    
})

 conversations = $lisa_conversation.start_watching_conversations([
    ["#design", "#typography"], ["#fonts"], ["#typeface"], ["#Design", "#photoshop"],
    ['#android'], ["#googleplay"],
    ['#marketing', '#seo'], ["#MarketingTips"],
    ['#growthhacking'],
    ['#android', "#app"], 
    ['#iphone', '#app'], 
    ["#iphone", "#jailbreak"],
    ["#app", "#development"],
    ['#startup'], 
    ["#Entrepreneur"], ["#Venture", "#Capital"], ["#Crowdfunding", "startup"],
    ['#cloud', '#analytics'], 
    ["#windows", "#mobile"], ["#winmo"],
    ["#ycombinator"], ["#Startup", "#School"],
    ["#funding", "#invest"],
    ["#social", "#media"],
    ["#WebsiteDesign"],
    ["#WebDevelopment"],
    ["#angularjs"], ["#javascript"], ["#ubuntu"], ["#smartwatch"], 
    ["#android", "#wear"], ["#moto360"], ["#IFA2014"],
    ["rubyonrails"], ["#backbonejs"], ["#apple", '#swift'], ["#python"], ["#lamp", "#php"],
    ["#startupchile"]

    # ['food', 'delicious'],
    # ['food', 'cook', 'recipe'],
    # ['cake', 'recipe'],
    # ["italian", "cuisine"],
    # ["cuisine"],
    # ["celebrity", "chef"],
    # ["top", "chef"],
    # ["masterchef"],
    # ["ferrari"],
    # ["bmw"],
    # ["honda"],
    # ["electric", "cars"],
    # ["hybrid", "cars"],
    # ["sushi"], ["grilled", "food"], ["salad"], ["johnny", "rockets"], ["lebanese", "food"], ["fat", "lulu"], 
    # ["italian", "pizza"],
    # ["pagani"], ["mclaren"], 
    # ["top", "gear"]
 ])

 pp conversations



