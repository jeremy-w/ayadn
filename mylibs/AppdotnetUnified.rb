class AyaDN
	class AppdotnetUnified
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts/stream/unified?access_token='
			@token = token
		end
		def getUnified
			@url += @token + '&include_deleted=0&include_directed_posts=1&include_html=0'
			response = RestClient.get(@url)
			return response.body
		end
		def getJSON
			return getUnified()
		end
		def getText
			stream = ""
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
				stream += 'Le ' + createdDay.cyan + ' a ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + '"' + coloredPost + '"' + "\n\n"
				postId = item['id']
				stream += "Post ID : ".cyan + postId.to_s.brown
				if !links.empty?
					links.each do |link|
						linkURL = link['url']
						stream += " - " + "Lien : ".cyan + linkURL.brown + " "
					end
				end
				stream += "\n\n\n"
			end
			return stream
		end
	end
end