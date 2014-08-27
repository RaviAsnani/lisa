require "httparty"
require 'htmlentities'

class GoogleImageSearch

	def search(query)
		response = HTTParty.get('https://ajax.googleapis.com/ajax/services/search/images', 
								:query => {:v => "1.0", :q =>  HTMLEntities.new.decode(query), 
											:start => 0, :rsz => "large", :hl => "en", :gl => "in"}, 
								:headers => {"User-Agent" => "Google Bot", "Referer" => "http://www.google.com"})
		response_json = JSON.parse(response.body)
		if response_json != nil and response_json.keys.index("responseData") != nil
			if response_json["responseData"] != nil and response_json["responseData"]["results"] != nil
				return parse_success_response(response_json)
			end
		end

		return nil
	end


	def parse_success_response(response_json)
		results = []
		objects = response_json["responseData"]["results"]
		objects.each { |object|
			results << {
				:url => object["url"],
				:width => object["width"].to_i,
				:height => object["height"].to_i
			}
		}	
		return results
	end

end