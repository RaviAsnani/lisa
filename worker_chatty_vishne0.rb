#!/usr/bin/env ruby

require "./lisa_the_birdie"


# vishne0
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





lisa = LisaTheChattyBird.new({
  :auth => $auth,
  :name => "Lisa Realtime"
})

lisa.start_chatting



