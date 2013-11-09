class AyaDN
	class AppdotnetUserPosts
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/'
			@token = token
		end
		def getPosts(name)
			@url += "#{name}" + "/posts" + "/?access_token=#{@token}"
			response = RestClient.get(@url)
			return response.body
		end
		def getJSON(name)
		 	return getPosts(name)
		end
		def getUserPosts(name)
			userPostsStream = ""
			hashOfResponse = JSON.parse(getJSON(name))
			adnData = hashOfResponse['data']
			adnDataReverse = adnData.reverse
			adnDataReverse.each do |item|
				content = Array.new
				hasText = item['text']
				if hasText != nil
					splitted = hasText.split(" ")
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
				else
					content.push("--Deleted post--".red)
				end
				coloredPost = content.join(" ")
				userName = item['user']['username']
				createdAt = item['created_at']
				createdDay = createdAt[0...10]
				createdHour = createdAt[11...19]
				links = item['entities']['links']
				userPostsStream += "\nLe " + createdDay.cyan + ' a ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + coloredPost + "\n\n"
				postId = item['id']
				userPostsStream += "Post ID : ".cyan + postId.to_s.brown
				if !links.empty?
					links.each do |link|
						linkURL = link['url']
						userPostsStream += " - " + "Lien : ".cyan + linkURL.brown + " "
					end
				end
				userPostsStream += "\n\n"
			end
			return userPostsStream
		end
	end
end