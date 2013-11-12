# encoding: utf-8
class AyaDN
	class AppdotnetFollow
		@token
		@url
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/'
			@token = token
		end
		def followUser(userID)
			clientFollowed = AyaDN::AppdotnetUserInfo.new(@token)
			youFollow, followsYou = clientFollowed.getUserFollowInfo(userID)
			if youFollow == true
				puts "You're already following this user.\n\n".red
				exit
			end
			if youFollow == false
				@url += "#{userID}" + "/follow" + "/?access_token=#{@token}"
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
		def unFollowUser(userID)
			clientFollowed = AyaDN::AppdotnetUserInfo.new(@token)
			youFollow, followsYou = clientFollowed.getUserFollowInfo(userID)
			if youFollow == false
				puts "You're already not following this user.\n\n".red
				exit
			end
			if youFollow == true
				@url += "#{userID}" + "/follow" + "/?access_token=#{@token}"
				uri = URI("#{@url}")
				https = Net::HTTP.new(uri.host,uri.port)
				https.use_ssl = true
				https.verify_mode = OpenSSL::SSL::VERIFY_NONE
				request = Net::HTTP::Delete.new(uri.path)
				request["Authorization"] = "Bearer #{@token}"
				request["Content-Type"] = "application/json"
				response = https.request(request)
				return response
			end
		end

	end
end