require "httparty"
require 'cgi'

class GoogleImageSearch

	def search(query)
		response = HTTParty.get('https://ajax.googleapis.com/ajax/services/search/images', 
								:query => {:v => "1.0", :q => CGI.escape(query), 
											:start => 0, :rsz => "large", :hl => "en", :gl => "in"}, 
								:headers => {"User-Agent" => "Google Bot", "Referer" => "http://www.google.com"})
		response_json = JSON.parse(response.body)
		if response_json != nil and response_json.keys.index("responseData") != nil
			return parse_success_response(response_json)
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