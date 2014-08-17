#!/usr/bin/env ruby

require "./lisa_the_birdie"


# Main execution starts here
lisa = LisaTheChattyBird.new({
    :auth => {
      :consumer_key => 'fl8Xb0Lv6CkKdbNAMGB8mBUrG',
      :consumer_secret =>'mAtdDResuDJp9xwsInihXD5rcDpMEnJ4nMRtOGtcNSH0agbZ28',
      :token =>'2592724712-o8gSOnGMuwUfaXcB1nGR1hrUIk9YkSDrBX108Fx',
      :secret => 'Qw8AQGMR1K2HAWfZ6GkACLOG66I6UdVIYF9iQcdHUQKgA'
    }
  })

lisa.start_chatting