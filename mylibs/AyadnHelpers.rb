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
def buildPost(postHash)
	postString = ""
	postHash.each do |item|
		postText = item['text']
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
class ErrorWarning
	def errorUsername(arg)
		raise ArgumentError.new("\n\n->".brown + " #{arg}".reddish + " n'est pas un ".red + "@username\n".green)
	end
	def errorPostID(arg)
		raise ArgumentError.new("\n\n->".brown + " #{arg}".reddish + " n'est pas un Post ID\n".red)
	end
	def errorHTTP
		raise ArgumentError.new("\n\n-> ".brown + "Erreur de connection.\n".red)
		exit
	end
	def globalError
		72.times{print "*".reverse_color}
		print "\n"
		15.times{print "-".reverse_color}
		print "Une erreur de type inconnu s'est produite.".reverse_color
		15.times{print "-".reverse_color}
		puts "\nN'hésitez pas à m'envoyer un message -> ".reverse_color + "@ericd".reverse_color + " pour m'aider à débugger !".reverse_color
		72.times{print "*".reverse_color}
		return nil
	end
	def syntaxError(arg)
		raise ArgumentError.new("\n\n-> ".brown + "#{arg}".magenta + " n'est pas une option valide. Il s'agit probablement d'une erreur de frappe...\n".red)
	end
end
class ClientStatus
	def getUnified
		s = "\nChargement du Unified Stream...\n".green
	end
	def getGlobal
		s = "\nChargement du Global Stream...\n".green
	end
	def infosUser(arg)
		s = "\nChargement des informations sur ".green + "#{arg}...\n".reddish
	end
	def postsUser(arg)
		s = "\nChargement des posts de ".green + "#{arg}...\n".reddish
	end
	def mentionsUser(arg)
		s = "\nChargement des posts mentionnant ".green + "#{arg}...\n".reddish
	end
	def starsUser(arg)
		s = "\nChargement des posts favoris de ".green + "#{arg}...\n".reddish
	end
	def getHashtags(arg)
		s = "\nChargement des posts contenant ".green + "##{arg}...\n".blue
	end
	def sendPost
		s = "\nEnvoi du post...\n".green
	end
	def getDetails
		s = "\nDétails du post...\n".green
	end
	def getPostReplies(arg)
		s = "Chargement de la conversation autour du post ".green + "#{arg}".reddish
	end
	def writePost
		s = "\n256 caractères maximum, validez avec Entrée (return) ou annulez avec Echap (esc).\n".green
		s += "\nEntrez votre texte : ".cyan
	end
end
class String
	def is_integer?
	  self.to_i.to_s == self
	end
end




