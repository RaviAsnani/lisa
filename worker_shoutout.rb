#!/usr/bin/env ruby

require "./lisa_the_birdie"

lisa = LisaTheBirdie.new({
    :auth => {
      :consumer_key => 'fl8Xb0Lv6CkKdbNAMGB8mBUrG',
      :consumer_secret =>'mAtdDResuDJp9xwsInihXD5rcDpMEnJ4nMRtOGtcNSH0agbZ28',
      :token =>'2592724712-o8gSOnGMuwUfaXcB1nGR1hrUIk9YkSDrBX108Fx',
      :secret => 'Qw8AQGMR1K2HAWfZ6GkACLOG66I6UdVIYF9iQcdHUQKgA'
    },
    :exclude => ["yobitchme", "Easy_Branches"]
  })

LisaTheBirdie.looper do
  lisa.shoutout_for_app_feedback  
end
