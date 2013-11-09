class AyaDN
	class AppdotnetStarredPosts
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/'
			@token = token
		end
		def getPosts(name)
			@url += "#{name}" + "/stars" + "/?access_token=#{@token}" + "&include_deleted=0&include_html=0"
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
		def getStarredPosts(name)
			hashOfResponse = JSON.parse(getJSON(name))
			starredPosts = hashOfResponse['data']
			if starredPosts == nil
				exit
			end
			starredPostsReverse = starredPosts.reverse
			resp = buildPost(starredPostsReverse)
			return resp
		end
	end
end