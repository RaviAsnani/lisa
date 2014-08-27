require "httparty"
require 'cgi'

class GoogleImageSearch

	def search(query)
		response = HTTParty.get('https://ajax.googleapis.com/ajax/services/search/images', 
								:query => {:v => "1.0", :q => CGI.escape(@query), 
											:start => 0, :rsz => "large", :hl => "en", :gl => "in"}, 
								:headers => {"User-Agent" => "Google Bot", "Referer" => "http://www.google.com"})
		response_json = JSON.parse(response.body)
		if response_json.keys.index("responseData") != nil
			return parse_success_response(response_json)
		end

		return nil
	end


	def parse_success_response(objects)
		results = []
		objects.each { |object|
			results << {
				:url => object["url"],
				:width => object["width"],
				:height => object["height"]
			}
		}	
		return results
	end

end