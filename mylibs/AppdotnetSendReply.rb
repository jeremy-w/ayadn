class AyaDN
	class AppdotnetSendReply
		@token
		def initialize(token)
			@token = token
		end
		def replyPost(postID)
			puts "Replying to post ".cyan + "#{postID}...\n".brown
			puts "Insert the @username(s) you're replying to at the beginning of your post.".red
			# récup mentions dans le post
			# formatte le post avec @username au début suivi des autres @mentionnés !
			status = ClientStatus.new
			puts status.writePost()
			client = AyaDN::AppdotnetSendPost.new(@token)
			puts client.composePost(postID)
		end
	end
	class AppdotnetStarPost
		@token
		def initialize(token)
			@token = token
		end
		def starPost(postID)

		end
	end
end