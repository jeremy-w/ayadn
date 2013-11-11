class AyaDN
	class AppdotnetSendReply
		@token
		def initialize(token)
			@token = token
		end
		def replyPost(postID)
			puts "Replying to post ".cyan + "#{postID}...\n".brown
			# récup mentions dans le post
			puts "Extracting mentions...\n".cyan
			client = AyaDN::AppdotnetPostInfo.new(@token)
			# returns the posts's raw text
			rawMentionsText = client.getPostMentions(postID)
			# get mentions
			content = Array.new
			splitted = rawMentionsText.split(" ")
			splitted.each do |word|
				if word =~ /^@/
					content.push(word)
				end
			end
			mentionsList = content.join(" ")
			# go!
			status = ClientStatus.new
			puts status.writePost()
			client = AyaDN::AppdotnetSendPost.new(@token)
			puts client.composePost(postID, mentionsList)
		end
	end
end