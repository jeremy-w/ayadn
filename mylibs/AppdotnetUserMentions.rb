class AyaDN
	class AppdotnetUserMentions
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/users/'
			@token = token
		end
		def getMentions(name)
			@url += "#{name}" + "/mentions" + "/?access_token=#{@token}"
			response = RestClient.get(@url)
			return response.body
		end
		def getJSON(name)
		 	return getMentions(name)
		end
		def getUserMentions(name)
			userMentionsStream = ""
			hashOfResponse = JSON.parse(getJSON(name))
			userMentions = hashOfResponse['data']
			userMentionsReverse = userMentions.reverse
			userMentionsReverse.each do |item|
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
				userMentionsStream += "\nLe " + createdDay.cyan + ' a ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + coloredPost + "\n\n"
				postId = item['id']
				userMentionsStream += "Post ID : ".cyan + postId.to_s.brown
				if !links.empty?
					userMentionsStream += " - " + "Lien : ".cyan
					links.each do |link|
						linkURL = link['url']
						userMentionsStream += linkURL.brown + " "
					end
				end
				userMentionsStream += "\n\n"
			end
			return userMentionsStream
		end
	end
end