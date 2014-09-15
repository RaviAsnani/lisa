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






lisa = LisaTheChattyBird.new({
  :auth => $auth,
  :name => "Lisa Realtime"
})

lisa.start_chatting



