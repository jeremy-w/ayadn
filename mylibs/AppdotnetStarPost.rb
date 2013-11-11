class AyaDN
	class AppdotnetStarPost
		@token
		@url
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/'
			@token = token
		end
		def starPost(postID)
			clientStarred = AyaDN::AppdotnetPostInfo.new(@token)
			isStarred, isRepost = clientStarred.getPostStarred(postID)
			if isRepost != nil
				puts "This post is a repost. Please star the parent post.\n\n".red
				exit
			end
			if isStarred == false
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
			else
				puts "Canceled: the post is already starred.\n\n".red
				exit
			end
		end
		def unstarPost(postID)
			clientStarred = AyaDN::AppdotnetPostInfo.new(@token)
			isStarred, isRepost = clientStarred.getPostStarred(postID)
			if isStarred == true
				@url += "#{postID}" + "/star" + "/?access_token=#{@token}"
				uri = URI("#{@url}")
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = true
				https.verify_mode = OpenSSL::SSL::VERIFY_NONE
				request = Net::HTTP::Delete.new(uri.path)
				request["Authorization"] = "Bearer #{@token}"
				request["Content-Type"] = "application/json"
				response = https.request(request)
				return response
			else
				puts "Canceled: the post wasn't already starred.\n\n".red
				exit
			end
		end
	end
end