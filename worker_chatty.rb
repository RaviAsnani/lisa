#!/usr/bin/env ruby

require "./lisa_the_birdie"


# Main execution starts here
lisa = LisaTheChattyBird.new({
    :auth => {
      :consumer_key => '07y02Rx3pjpVlAqmwiLZeONBQ',
      :consumer_secret =>'SFN4ennNrCRu8eL7piWRRvJrpupi8IV5dDcN3gnPcms97LlRAt',
      :token =>'2592724712-sATvge1OdeqOd1zpE2riTKpiPaCmn0o3Jarnppe',
      :secret => 'XtH5VQKXVURUDfQ0GPqxrcYO4wGMqdUcLnF26PP0YoVz0'
    },
    :name => "Lisa Realtime testing"
  })

#lisa.start_chatting
lisa.start_chatting_with_friends_of(["pjain"])