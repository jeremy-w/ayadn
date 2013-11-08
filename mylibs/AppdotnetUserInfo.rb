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
			response = RestClient.get(@url)
			return response.body
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
				userShow += "Nom : ".red + userRealName.cyan + "\n"
			end
			if userInfo['description'] != nil
				userDescr = userInfo['description']['text']
			else
				userDescr = "Pas de description disponible.".red
			end
			if userInfo['timezone'] != nil
				userTimezone = userInfo['timezone']
				userShow += "Fuseau horaire : ".red + userTimezone.cyan + "\n"
			end
			userFollows = userInfo['follows_you']
			userFollowed = userInfo['you_follow']
			userShow += theName.red
			if userFollows == true
				userShow += " vous suit\n".green
			else
				userShow += " ne vous suit pas\n".reddish
			end
			if userFollowed == true
				userShow += "Vous suivez ".green + theName.red
			else
				userShow += "Vous ne suivez pas ".reddish + theName.red
			end
			userPosts = userInfo['counts']['posts']
			userFollowers = userInfo['counts']['followers']
			userFollowing = userInfo['counts']['following']
			userShow += "\nPosts: ".red + userPosts.to_s.cyan + "\nFollowers: ".red + userFollowers.to_s.cyan + "\nFollowing: ".red + userFollowing.to_s.cyan
			userShow += "\nBio : \n".red + userDescr + "\n\n"
			return userShow
		end
	end
end