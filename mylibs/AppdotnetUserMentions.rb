class AyaDN
	class AppdotnetUserMentions
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/'
			@token = token
		end
		def getMentions(name)
			@url += "#{name}" + "/mentions" + "/?access_token=#{@token}"
			response = RestClient.get(@url)
			return response.body
		end
		def getJSON(name)
		 	return getMentions(name)
		end
		def getUserMentions(name)
			hashOfResponse = JSON.parse(getJSON(name))
			userMentions = hashOfResponse['data']
			userMentionsReverse = userMentions.reverse
			resp = buildPost(userMentionsReverse)
			return resp
		end
	end
end