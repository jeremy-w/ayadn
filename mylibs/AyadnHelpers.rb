# encoding: utf-8
def colorize(contentText)
	content = Array.new
	splitted = contentText.split(" ")
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
end
def buildUsersList(usersHash)
	usersString = ""
	usersHash.each do |item|
		userName = item['username']
		userRealName = item['name']

		userHandle = "@" + userName
		usersString += userHandle.green + " #{userRealName}\n".cyan
	end
	usersString += "\n\n"
	return usersString
end
def buildPost(postHash)
	postString = ""
	postHash.each do |item|
		postText = item['text']
		if postText != nil
			coloredPost = colorize(postText)
		else
			coloredPost = "--Post deleted--".red
		end
		userName = item['user']['username']
		createdAt = item['created_at']
		createdDay = createdAt[0...10]
		createdHour = createdAt[11...19]
		links = item['entities']['links']
		postId = item['id']
		#postString += "---\n".brown
		postString += "Post ID: ".cyan + postId.to_s.green
		#postString += "\nThe "
		postString += " - "
		postString += createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green + "\n" + coloredPost + "\n"
		if !links.empty?
			postString += "Link: ".cyan
			links.each do |link|
				linkURL = link['url']
				postString += linkURL.brown + " \n"
			end
		end
		#postString += "---\n".brown
		postString += "\n\n"
	end
	return postString
end
def buildCheckinsPosts(postHash)
	postString = ""
	geoString = ""
	postHash.each do |item|
		postText = item['text']
		if postText != nil
			coloredPost = colorize(postText)
		else
			coloredPost = "--Post deleted--".red
		end
		userName = item['user']['username']
		createdAt = item['created_at']
		createdDay = createdAt[0...10]
		createdHour = createdAt[11...19]
		links = item['entities']['links']
		postId = item['id']
		#postString += "---\n".brown
		postString += "Post ID: ".cyan + postId.to_s.green
		#postString += "\nThe "
		postString += " - "
		postString += createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green + "\n" + coloredPost + "\n"
		if !links.empty?
			postString += "Link: ".cyan
			links.each do |link|
				linkURL = link['url']
				postString += linkURL.brown + " \n"
			end
		end
		sourceName = item['source']['name']
		sourceLink = item['source']['link']
		# plusieurs annotations par post, dont checkin
		typesList = item['annotations']

		type = typesList[0]['type']
		value = typesList[0]['value']
		# puts type
		# puts value


		if  type == "net.app.core.checkin"
			chName = value['name']
			chAddress = value['address']
			chLocality = value['locality']
			chRegion = value['region']
			chPostcode = value['postcode']
			chCountryCode = value['country_code']
			fancy = chName.length + 7
			postString += "-" * fancy
			postString += "\n-Name: ".green + chName.upcase
			postString += "\n-Address: ".green + chAddress
			postString += "\n-Locality: ".green + chLocality
			postString += "\n-State/Region: ".green + chRegion + " (" + chCountryCode.upcase + ")"
			postString += "\n-Posted with: ".green + sourceName + " [#{sourceLink}]"
		end
		
		postString += "\n\n"
	end
	return postString
end
def buildUniquePost(postHash)
	postString = ""
	postText = postHash['text']
	if postText != nil
		coloredPost = colorize(postText)
	else
		coloredPost = "--Post deleted--".red
	end
	userName = postHash['user']['username']
	createdAt = postHash['created_at']
	createdDay = createdAt[0...10]
	createdHour = createdAt[11...19]
	links = postHash['entities']['links']
	postId = postHash['id']
	postString += "\n\nPost ID: ".cyan + postId.to_s.green
	postString += " - " + createdDay.cyan + ' at ' + createdHour.cyan + ' by ' + "@".green + userName.green + "\n\n" + coloredPost + "\n" + "\n"
	if !links.empty?
		postString += "Link: ".cyan
		links.each do |link|
			linkURL = link['url']
			postString += linkURL.brown + " "
		end
	end
	postString += "\n\n"
	return postString
end
class ErrorWarning
	def errorMaxChars
		raise ArgumentError.new("\n\nToo many characters. 256 max.\n\n".red)
	end
	def errorUsername(arg)
		raise ArgumentError.new("\n\n->".brown + " #{arg}".reddish + " is not a @username\n\n".red)
	end
	def errorPostID(arg)
		raise ArgumentError.new("\n\n->".brown + " #{arg}".reddish + " is not a Post ID\n\n".red)
	end
	def errorInfos(arg)
		raise ArgumentError.new("\n\n->".brown + " #{arg}".reddish + " isn't a @username nor a Post ID\n\n".red)
	end
	def errorHTTP
		raise ArgumentError.new("\n\n-> ".brown + "Connexion error.\n\n".red)
		exit
	end
	def globalError
		63.times{print "*".reverse_color}
		print "\n"
		26.times{print "-".reverse_color}
		print "UNKNOW ERROR".reverse_color
		25.times{print "-".reverse_color}
		puts "\nDon't hesitate to send me a message -> ".reverse_color + "@ericd" + " to help me debug!".reverse_color
		63.times{print "*".reverse_color}
		puts "\n"
		return nil
	end
	def syntaxError(arg)
		raise ArgumentError.new("\n\n-> ".brown + "#{arg}".magenta + " is not a valid option\n\n".red)
	end
	def errorReply(arg)
		raise ArgumentError.new("\n\n-> ".brown + "#{arg}".reddish + " is not a Post ID.\n\n".red)
	end
end
class ClientStatus
	def getUnified
		s = "\nLoading the Unified Stream...\n".green
	end
	def getGlobal
		s = "\nLoading the Global Stream...\n".green
	end
	def whoReposted(arg)
		s = "\nLoading informations on ".green + "#{arg}...\n".reddish
	end
	def infosUser(arg)
		s = "\nLoading informations on ".green + "#{arg}...\n".reddish
	end
	def postsUser(arg)
		s = "\nLoading posts of ".green + "#{arg}...\n".reddish
	end
	def mentionsUser(arg)
		s = "\nLoading posts mentionning ".green + "#{arg}...\n".reddish
	end
	def starsUser(arg)
		s = "\nLoading ".green + "#{arg}".reddish + "'s favorite posts...\n".green
	end
	def starsPost(arg)
		s = "\nLoading users who starred post ".green + "#{arg}".reddish + "...\n" .green
	end
	def getHashtags(arg)
		s = "\nLoading posts containing ".green + "##{arg}...\n".blue
	end
	def sendPost
		s = "\nSending post...\n".green
	end
	def getDetails
		s = "\nLoading informations...\n".green
	end
	def getPostReplies(arg)
		s = "Loading the conversation around post ".green + "#{arg}\n".reddish
	end
	def writePost
		s = "\n256 characters max, validate with [Enter] or cancel with [esc].\n".green
		s += "\nType your text: ".cyan
	end
	def writeReply(arg)
		s = "\nLoading informations of post #{arg}...\n".green
	end
end
class String
	def is_integer?
	  self.to_i.to_s == self
	end
end




