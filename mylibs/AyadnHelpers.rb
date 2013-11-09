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
def buildPost(postHash)
	postString = ""
	postHash.each do |item|
		postText = item['text']
		# coloredPost = colorize(postText)
		if postText != nil
			coloredPost = colorize(postText)
		else
			coloredPost = "--Post supprimé--".red
		end
		userName = item['user']['username']
		createdAt = item['created_at']
		createdDay = createdAt[0...10]
		createdHour = createdAt[11...19]
		links = item['entities']['links']
		postString += "\nLe " + createdDay.cyan + ' à ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + coloredPost + "\n\n"
		postId = item['id']
		postString += "Post ID : ".cyan + postId.to_s.brown
		if !links.empty?
			postString +=  " - " + "Lien : ".cyan
			links.each do |link|
				linkURL = link['url']
				postString += linkURL.brown + " "
			end
		end
		postString += "\n\n\n"
	end
	return postString
end
def buildUniquePost(postHash)
	postString = ""
	postText = postHash['text']
	if postText != nil
		coloredPost = colorize(postText)
	else
		coloredPost = "--Post supprimé--".red
	end
	userName = postHash['user']['username']
	createdAt = postHash['created_at']
	createdDay = createdAt[0...10]
	createdHour = createdAt[11...19]
	links = postHash['entities']['links']
	postString += "\nLe " + createdDay.cyan + ' à ' + createdHour.cyan + ' par ' + "@".green + userName.green + " :\n" + "---\n".red + coloredPost + "\n\n"
	postId = postHash['id']
	postString += "Post ID : ".cyan + postId.to_s.brown
	if !links.empty?
		postString +=  " - " + "Lien : ".cyan
		links.each do |link|
			linkURL = link['url']
			postString += linkURL.brown + " "
		end
	end
	postString += "\n\n\n"
	return postString
end