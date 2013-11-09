class AyaDN
	class AppdotnetGlobal
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/stream/global?access_token='
			@token = token
		end
		def getGlobal
			@url += @token + '&include_deleted=0&include_html=0'
			response = RestClient.get(@url)
			return response.body
		end
		def getJSON
			return getGlobal()
		end
		def getText
			globalStream = ""
			hashOfResponse = JSON.parse(getJSON())
			adnData = hashOfResponse['data']
			adnDataReverse = adnData.reverse
			adnDataReverse.each do |item|
				content = Array.new
				splitted = item['text'].split(" ")
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
				globalStream += 'Le ' + createdDay.cyan + ' à ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + '"' + coloredPost + '"' + "\n\n"
				postId = item['id']
				globalStream += "Post ID : ".cyan + postId.to_s.brown
				if !links.empty?
					links.each do |link|
						linkURL = link['url']
						globalStream += " - " + "Lien : ".cyan + linkURL.brown + " "
					end
				end
				globalStream += "\n\n\n"
			end
			return globalStream
		end
	end
end