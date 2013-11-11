# encoding: utf-8
class AyaDN
	class AppdotnetUserInfo
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/'
			@token = token
		end
		def getUserURL(name)
			@url += "#{name}" + "/?access_token=#{@token}"
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON(name)
		 	return getUserURL(name)
		end
		def getUserInfo(name)
			hashOfResponse = JSON.parse(getJSON(name))
			userInfo = hashOfResponse['data']
			userName = userInfo['username']
			userShow = "\n--- @".brown + userName.brown + " ---\n".brown
			theName = "@" + userName
			if userInfo['name'] != nil
				userRealName = userInfo['name']
				userShow += "Name: ".red + userRealName.cyan + "\n"
			end
			if userInfo['description'] != nil
				userDescr = userInfo['description']['text']
			else
				userDescr = "No description available.".red
			end
			if userInfo['timezone'] != nil
				userTimezone = userInfo['timezone']
				userShow += "Timezone: ".red + userTimezone.cyan + "\n"
			end
			userShow += theName.red


			# this will be obsolete once the app has its own token
			if name != "me"
				userFollows = userInfo['follows_you']
				userFollowed = userInfo['you_follow']
				if userFollows == true
					userShow += " follows you\n".green
				else
					userShow += " doesn't follow you\n".reddish
				end
				if userFollowed == true
					userShow += "You follow ".green + theName.red
				else
					userShow += "You don't follow ".reddish + theName.red
				end
			else
				userShow += ": yourself!".cyan
			end
			#
			
			userPosts = userInfo['counts']['posts']
			userFollowers = userInfo['counts']['followers']
			userFollowing = userInfo['counts']['following']
			userShow += "\nPosts : ".red + userPosts.to_s.cyan + "\nFollowers : ".red + userFollowers.to_s.cyan + "\nFollowing : ".red + userFollowing.to_s.cyan
			userShow += "\nBio : \n".red + userDescr + "\n\n"
			return userShow
		end
	end
end