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
			@url += "#{postID}" + "/?access_token=#{@token}&include_annotations=1&include_html=0" #
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

		def savePost(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			return hashOfResponse
		end

		def getSinglePost(action, postID)
			if action == "call"
				hashOfResponse = JSON.parse(getJSON(postID))
				return hashOfResponse
			elsif action == "load"
				# load post file and return content
				fileContent = Hash.new
				File.open("./data/posts/#{postID}.post", "r") do |f|
					fileContent = f.gets
				end
				hashOfResponse = eval(fileContent)
				return hashOfResponse
			else
				puts "syntax error"
				exit
			end
		end

		def getOriginalPost(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postInfo = hashOfResponse['data']
			isRepost = postInfo['repost_of']
			goToID = isRepost['id']
		end

		def ifExists(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postInfo = hashOfResponse['data']
			isTherePost = postInfo['text']
			isYours = postInfo['user']['username']
			return isTherePost, isYours
		end

		def getPostStarred(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postInfo = hashOfResponse['data']
			youStarred = postInfo['you_starred']
			isRepost = postInfo['repost_of']
			return youStarred, isRepost
		end

		def getPostMentions(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postInfo = hashOfResponse['data']
			userName = postInfo['user']['username']
			rawText = postInfo['text']
			isRepost = postInfo['repost_of']
			return rawText, userName, isRepost
		end

		def getPosterName(postID)
			hashOfResponse = JSON.parse(getJSON(postID))
			postData = hashOfResponse['data']
			userName = postData['user']['username']
			return userName
		end

		def getPostInfo(action, postID)
			hashOfResponse = getSinglePost(action, postID)

			postInfo = hashOfResponse['data']

			thePostId = postInfo['id']
			postText = postInfo['text']
			userName = postInfo['user']['username']
			realName = postInfo['user']['name']
			theName = "@" + userName
			userFollows = postInfo['follows_you']
			userFollowed = postInfo['you_follow']
			
			builder = AyaDN::BuildPosts.new
			coloredPost = builder.colorize(postText)

			createdAt = postInfo['created_at']
			createdDay = createdAt[0...10]
			createdHour = createdAt[11...19]
			links = postInfo['entities']['links']

			postDetails = "\nThe " + createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green
			if !realName.empty?
				postDetails += " \[#{realName}\]".reddish
			end
			postDetails += ":\n"
			postDetails += "\n" + coloredPost + "\n" + "\n" 
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

			postDetails += "\nReplies: ".cyan + numReplies.to_s.reddish
			postDetails += "  Reposts: ".cyan + numReposts.to_s.reddish
			postDetails += "  Stars: ".cyan + numStars.to_s.reddish

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



