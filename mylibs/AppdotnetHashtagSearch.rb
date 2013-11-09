class AyaDN
	class AppdotnetHashtagSearch
		@url
		def initialize
			@url = 'https://alpha-api.app.net/stream/0/posts/tag/'
		end
		def getHashtag(hashtag)
			@url += "#{hashtag}"
			response = RestClient.get(@url)
		end
		def getJSON(hashtag)
			return getHashtag(hashtag)
		end
		def getTaggedPosts(hashtag)
			hashOfResponse = JSON.parse(getJSON(hashtag))
			hashtagData = hashOfResponse['data']
			hashtagList = hashtagData.reverse
			resp = buildPost(hashtagList)
			return resp
		end
	end
end