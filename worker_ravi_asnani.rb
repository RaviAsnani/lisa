#!/usr/bin/env ruby

require "./lisa_the_birdie"


# LisaToolbox.looper do 

#   # Main execution starts here
#   lisa = LisaTheBirdie.new({
#       :auth => {
#         :consumer_key => 'xSk9IoxQbnxKbw0ebjuJ6sV5o',
#         :consumer_secret =>'Lyp1xWyReu7kgday1QOR7XN3JMA9OrB7LvBooKs3shciWimqat',
#         :token =>'137607844-Gzmkt1zs696XZnX3GpyT7Lba2rT7E6TAIORxA9LU',
#         :secret => '29eTALhvojnN3uRRqBTnI8k6Ej1pbDU0XhFjAS9vuui44'
#       },
#       :parse => {
#         :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
#         :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
#       },
#       :exclude => ["ravi_asnani"],
#       :lang => "en", 
#       :tweet => {
#         :min_retweet_count => 1, 
#         :min_star_count => 1,
#         :moderate_retweet_count => 3,
#         :moderate_star_count => 3,  
#         :high_retweet_count => 5,
#         :high_star_count => 5   # To get more starrable tweets into the honeypot :)
#       },
#       :user => {
#         :followers_to_friends_ratio => 0.3,
#         :min_followers_count => 500,
#         :min_star_count => 25,
#         :min_tweet_count => 1000,
#         :account_age => 0
#       }         
#     })

#   lisa.rate_limit(:looper_internal) {
#     puts "\n\n=================ravi_asnani===================="
#     keywords = [["food", "recipe"], ["tasty", "delicious"], ["saveur", "@Foodie", "@FoodNetwork"]]
#     keywords.shuffle.each do |keyword_set|
#       lisa.feast_on_keywords(keyword_set)
#     end
#   }

# end


elite_lisa = LisaTheEliteTweetMaker.new({
  :auth => {
      :consumer_key => 'xSk9IoxQbnxKbw0ebjuJ6sV5o',
      :consumer_secret =>'Lyp1xWyReu7kgday1QOR7XN3JMA9OrB7LvBooKs3shciWimqat',
      :token =>'137607844-Gzmkt1zs696XZnX3GpyT7Lba2rT7E6TAIORxA9LU',
      :secret => '29eTALhvojnN3uRRqBTnI8k6Ej1pbDU0XhFjAS9vuui44'
  },
  :parse => {
    :application_id => "ZkdRD4LbeKFxkaviTOmOY29eQ6VaPNV4h96N4qXV",
    :api_key => "yVnIz9AoDA3XlZPEMlG7tR9icMdcimm6Cvdxlush" 
  },
  :myself => "ravi_asnani"
})

LisaToolbox.looper do 
  elite_lisa.make_elite_tweets_for_keyword_cloud(
      [
        ['food', 'delicious'],
        ['food', 'cook', 'recipe'],
        ['vegetarian', 'vegan'], ['nonveg'],
        ['cake', 'recipe'],
        ['cheese'], ['burger'], 
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
        ["sushi"], ["grilled", "food"], ["salad"], ["johny", "rockets"], ["lebanese", "food"], ["fat", "lulu"], ["pizza"],
        ["pagani"], ["mclaren"], ["top", "gear"]
      ]
    )
end


