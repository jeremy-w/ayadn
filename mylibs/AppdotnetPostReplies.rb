# encoding: utf-8
class AyaDN
	class AppdotnetPostReplies
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/'
			@token = token
		end
		def getReplies(postID)
			@url += "#{postID}" + "/replies" + "/?access_token=#{@token}"
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON(postID)
			return getReplies(postID)
		end
		def getPostReplies(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postReplies = hashOfResponse['data']
			postRepliesReverse = postReplies.reverse
			resp = buildPost(postRepliesReverse)
			return resp
		end
	end
end