#!/usr/bin/env ruby

require "./lisa_the_birdie"

# yobitchme
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



lisa = LisaTheChattyBird.new({
  :auth => $auth,
  :name => "Lisa Realtime",
  :keywords => [
                  ["#design", "#typography"], ["#fonts"], ["#typeface"], ["#Design", "#photoshop"],
                  ['#android'], ["#googleplay"],
                  ['#marketing', '#seo'], ["#MarketingTips"],
                  ['#growthhacking'],
                  ['#android', "#app"], 
                  ['#iphone', '#app'], 
                  ["#iphone", "#jailbreak"],
                  ["#app", "#development"],
                  ['#startup'], ["#Entrepreneur"], ["#Venture", "#Capital"], ["#Crowdfunding", "startup"],
                  ['#cloud', '#analytics'], 
                  ["#windows", "#mobile"], ["#winmo"],
                  ["#ycombinator"], ["#Startup", "#School"],
                  ["#funding", "#invest"],
                  ["#social", "#media"],
                  ["#WebsiteDesign"],
                  ["#WebDevelopment"],
                  ["#angularjs"], ["#javascript"], ["#ubuntu"], ["#smartwatch"], 
                  ["#android", "#wear"], ["#moto360"], ["#IFA2014"],
                  ["rubyonrails"], ["#backbonejs"], ["#apple", '#swift'], ["#python"], ["#lamp", "#php"]
               ]
})

#lisa.start_chatting
lisa.start_chatting_with_friends_of(["500startups", "pjain"])



