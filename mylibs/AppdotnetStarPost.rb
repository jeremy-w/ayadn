class AyaDN
	class AppdotnetStarPost
		@token
		@url
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/'
			@token = token
		end
		def starPost(postID)
			@url += "#{postID}" + "/star" + "/?access_token=#{@token}"
			uri = URI("#{@url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			https.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"
			response = https.request(request)
			return response
		end
	end
end