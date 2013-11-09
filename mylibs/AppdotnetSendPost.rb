class AyaDN
	class AppdotnetSendPost
		@url
		@token
		def initialize(token)
			@url = 'https://alpha-api.app.net/stream/0/posts'
			@token = token
		end
		def createPost(text)
			uri = URI("#{@url}")
			https = Net::HTTP.new(uri.host,uri.port)
			https.use_ssl = true
			request = Net::HTTP::Post.new(uri.path)
			request["Authorization"] = "Bearer #{@token}"
			request["Content-Type"] = "application/json"

			payload = {
				"text" => "#{text}"
			}.to_json

			response = https.request(request, payload)
			callback = response.body

			blob = JSON.parse(callback)
			adnData = blob['data']
			postText = adnData['text']

			userSentPost = ""
			content = Array.new
			splitted = postText.split(" ")
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
			userName = adnData['user']['username']
			createdAt = adnData['created_at']
			createdDay = createdAt[0...10]
			createdHour = createdAt[11...19]
			links = adnData['entities']['links']
			userSentPost += "\nPost envoye le " + createdDay.cyan + ' a ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + coloredPost + "\n\n"
			postId = adnData['id']
			userSentPost += "Post ID : ".cyan + postId.to_s.brown
			if !links.empty?
				userSentPost += " - " + "Lien : ".cyan
				links.each do |link|
					linkURL = link['url']
					userSentPost += linkURL.brown + " "
				end
			end
			userSentPost += "\n\n\n"

		return userSentPost
		end
	end
end
