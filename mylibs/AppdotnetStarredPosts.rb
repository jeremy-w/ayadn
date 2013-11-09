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
			response = RestClient.get(@url)
			return response.body
		end
		def getJSON(name)
		 	return getPosts(name)
		end
		def getStarredPosts(name)
			userStarredPostsStream = ""
			hashOfResponse = JSON.parse(getJSON(name))
			starredPosts = hashOfResponse['data']
			if starredPosts == nil
				exit
			end
			starredPostsReverse = starredPosts.reverse
			starredPostsReverse.each do |item|
				content = Array.new
				textOfStarredPosts = item['text']
				splitted = textOfStarredPosts.split(" ")
				splitted.each do |word|
					if word =~ /^#/
						content.push(word.blue)
					elsif word =~ /^@/
						content.push(word.red)
					elsif word =~ /^http/ or word =~ /^photos.app.net/ or word =~ /^files.app.net/ or word =~ /^chimp.li/ or word =~ /^bli.ms/
						content.push(word.magenta)
					else
						content.push(word)
					end
				end
				coloredPost = content.join(" ")
				userName = item['user']['username']
				createdAt = item['created_at']
				createdDay = createdAt[0...10]
				createdHour = createdAt[11...19]
				links = item['entities']['links']
				userStarredPostsStream += "\nLe " + createdDay.cyan + ' a ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + coloredPost + "\n\n"
				postId = item['id']
				userStarredPostsStream += "Post ID : ".cyan + postId.to_s.brown
				if !links.empty?
					userStarredPostsStream +=  " - " + "Lien : ".cyan
					links.each do |link|
						linkURL = link['url']
						userStarredPostsStream += linkURL.brown + " "
					end
				end
				userStarredPostsStream += "\n\n"
			end
			return userStarredPostsStream
		end
	end
end