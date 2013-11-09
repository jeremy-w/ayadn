class AyaDN
	class AppdotnetUserPosts
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/'
			@token = token
		end
		def getPosts(name)
			@url += "#{name}" + "/posts" + "/?access_token=#{@token}"
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON(name)
		 	return getPosts(name)
		end
		def getUserPosts(name)
			hashOfResponse = JSON.parse(getJSON(name))
			adnData = hashOfResponse['data']
			adnDataReverse = adnData.reverse
			resp = buildPost(adnDataReverse)
			return resp
		end
	end
end