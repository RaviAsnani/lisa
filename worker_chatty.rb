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

lisa = LisaTheChattyBird.new({
  :auth => $auth,
  :name => "Lisa Realtime"
})

lisa.start_chatting