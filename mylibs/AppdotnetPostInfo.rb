# encoding: utf-8
class AyaDN
	class AppdotnetPostInfo
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/'
			@token = token
		end
		def getPostURL(postID)
			@url += "#{postID}" + "/?access_token=#{@token}"
			begin
				response = RestClient.get(@url)
				return response.body
			rescue
				warnings = ErrorWarning.new
				puts warnings.errorHTTP
			end
		end
		def getJSON(postID)
		 	return getPostURL(postID)
		end

		def getPostMentions(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postInfo = hashOfResponse['data']
			userName = postInfo['user']['username']
			rawText = postInfo['text']
			return rawText, userName
		end

		def getPosterName(postID)
			test = "from getPosterName after a reply to #{postID} "
			puts test
			hashOfResponse = JSON.parse(getJSON(postID))
			postData = hashOfResponse['data']
			userName = postData['user']['username']
			return userName
		end

		def getPostInfo(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postInfo = hashOfResponse['data']
			thePostId = postInfo['id']
			postText = postInfo['text']
			userName = postInfo['user']['username']
			realName = postInfo['user']['name']
			theName = "@" + userName
			userFollows = postInfo['follows_you']
			userFollowed = postInfo['you_follow']
			
			coloredPost = colorize(postText)

			createdAt = postInfo['created_at']
			createdDay = createdAt[0...10]
			createdHour = createdAt[11...19]
			links = postInfo['entities']['links']

			postDetails = "\nThe " + createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green
			if !realName.empty?
				postDetails += " \[#{realName}\]".reddish
			end
			postDetails += ":\n"
			postDetails += "\n" + coloredPost + "\n" + "\n\n" 
			postDetails += "Post ID: ".cyan + thePostId.to_s.green
			if !links.empty?
				links.each do |link|
					linkURL = link['url']
					postDetails += "\nLink: ".cyan + linkURL.brown
				end
			else
				postDetails += "\n"
			end
			postURL = postInfo['canonical_url']

			postDetails += "\nPost URL: ".cyan + postURL.brown

			numStars = postInfo['num_stars']
			numReplies = postInfo['num_replies']
			numReposts = postInfo['num_reposts']
			youReposted = postInfo['you_reposted']
			youStarred = postInfo['you_starred']
			sourceApp = postInfo['source']['name']
			locale = postInfo['user']['locale']
			timezone = postInfo['user']['timezone']

			postDetails += "\nReplies : ".cyan + numReplies.to_s.reddish
			postDetails += "  Reposts : ".cyan + numReposts.to_s.reddish
			postDetails += "  Stars : ".cyan + numStars.to_s.reddish

			if youReposted == true
				postDetails += "\nYou reposted this post.".cyan
			end
			if youStarred == true
				postDetails += "\nYou starred this post.".cyan
			end

			postDetails += "\nPosted with: ".cyan + sourceApp.reddish
			postDetails += "  Locale: ".cyan + locale.reddish
			postDetails += "  Timezone: ".cyan + timezone.reddish


			postDetails += "\n\n\n"
		return postDetails
		end
	end
end



