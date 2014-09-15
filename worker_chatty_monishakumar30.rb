#!/usr/bin/env ruby

require "./lisa_the_birdie"

$auth = {
  :consumer_key => 'HpSII4fDnC1esehkWYbtEXMJv',
  :consumer_secret =>'wcgRPxZZtcZLI7SPR7rnC1Ka2RNQfKWKp47bExTULS5cZgQkve',
  :token =>'178329023-kio4GiB67zH2YeKhDl0lAt1pYRlKlBzPnrhlQzG0',
  :secret => 'ydFhqCQeDOzl8YaBz3w6HdNCLVpab78h8ilmZqTcVwSDW'
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



