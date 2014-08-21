#!/usr/bin/env ruby

require "./lisa_the_birdie"

LisaToolbox.looper do 
  elite_tweeter = LisaTheEliteTweetMaker.new({:handle => "yobitchme"})
  elite_tweeter.make_elite_tweet("+food +recipe +cook")
end