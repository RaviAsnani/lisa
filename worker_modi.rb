#!/usr/bin/env ruby

require "./lisa_the_birdie"


LisaToolbox.looper do 

  # Main execution starts here
  lisa = LisaTheBirdie.new({
      :auth => {
        :consumer_key => '4e01CjniCAD5Tvmvbuw0chAiL',
        :consumer_secret =>'qwLU6Wbk6hz52KuSdrwqkLOlj72LRq12pkxOVcOiWu5rBrkkTR',
        :token =>'99530011-Iivab3OCgzFrl2nu7b0Pj5J8z93QbxIGL2cSOlCnV',
        :secret => 'imR8GB9dKYBMg9nVja6tEPaCUAQOb280R1HlRSvBKMMPo'
      },
      :parse => {
        :application_id => "66USFL6hbkAMk2woXbM7YfEfYL3VdkJGqkcKZ4a1",
        :api_key => "yRyk5sz5sqktraKUGnrQCuEwf4hMAxuTF1uKrvXz" 
      },
      :exclude => ["all_things_modi"]
    })

  lisa.rate_limit(:looper_internal) {
    puts "\n\n=================RUN 2===================="
    keywords = [["BJP", "narendra"], ["modi", "narendramodi"], ["indian politics"], 
                ["arunjaitley", "SushmaSwaraj"], ["AtalBajpeyi", "AmitShahOffice"], 
                ["naqvimukhtar", "SushilModi"], ["drharshvardhan", "smritiirani"],
                ["varungandhi80", "ShahnawazBJP"]]
    keywords.shuffle.each do |keyword_set|
      lisa.feast_on_keywords(keyword_set)
    end
  }

end