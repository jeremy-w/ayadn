class AyaDN
	class AppdotnetHashtagSearch
		@url
		def initialize
			@url = 'https://alpha-api.app.net/stream/0/posts/tag/'
		end
		def getHashtag(hashtag)
			@url += "#{hashtag}"
			response = RestClient.get(@url)
		end
		def getJSON(hashtag)
			return getHashtag(hashtag)
		end
		def getTaggedPosts(hashtag)
			hashtagStream = ""
			hashOfResponse = JSON.parse(getJSON(hashtag))
			hashtagList = hashOfResponse['data']
			hashtagList.each do |item|
				content = Array.new
				splitted = item['text'].split(" ")
				splitted.each do |word|
					if word =~ /^#/
						content.push(word.reddish)
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
				hashtagStream += 'Le ' + createdDay.cyan + ' a ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + '"' + coloredPost + '"' + "\n\n"
				postId = item['id']
				hashtagStream += "Post ID : ".cyan + postId.to_s.brown
				if !links.empty?
					links.each do |link|
						linkURL = link['url']
						hashtagStream += " - " + "Lien : ".cyan + linkURL.brown + " "
					end
				end
				hashtagStream += "\n\n\n"
			end
			return hashtagStream
		end
	end
end