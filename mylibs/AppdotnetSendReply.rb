class AyaDN
	class AppdotnetSendReply
		@token
		def initialize(token)
			@token = token
		end
		def replyPost(postID)
			puts "Replying to post ".cyan + "#{postID}...\n".brown
			puts "Extracting mentions...\n".cyan
			clientPostInfo = AyaDN::AppdotnetPostInfo.new(@token)
			rawMentionsText, replyingToThisUsername = clientPostInfo.getPostMentions(postID)
			content = Array.new
			splitted = rawMentionsText.split(" ")
			splitted.each do |word|
				if word =~ /^@/
					content.push(word)
				end
			end
			# detecte si mentions contiennent soi-même
			clientUserInfo = AyaDN::AppdotnetUserInfo.new(@token)
			myUsername = clientUserInfo.getUserName("me")
			myHandle = "@" + myUsername
			replyingToHandle = "@" + replyingToThisUsername
			newContent = Array.new
			if replyingToThisUsername != myUsername #si je ne suis pas en train de me répondre
				newContent.push(replyingToHandle) #rajouter le @username de à qui je réponds
			end
			content.each do |item|
				if item == myHandle #si je suis dans les mentions du post, m'effacer
					newContent.push("")
				else #sinon, garder la mention en question
					newContent.push(item)
				end
			end
			mentionsList = newContent.join(" ")
			# go!
			status = ClientStatus.new
			puts status.writePost()
			sendPost = AyaDN::AppdotnetSendPost.new(@token)
			puts sendPost.composePost(postID, mentionsList)
		end
	end
end