class AyaDN
	class AppdotnetSendReply
		@token
		def initialize(token)
			@token = token
		end
		def replyPost(postID)
			puts "\nEn réponse au post ".cyan + "#{postID}...\n".brown
			puts "INSEREZ LE/LES @USERNAME MANUELLEMENT AU DEBUT DE VOTRE TEXTE".red
			puts "Je m'occuperai de ce 'détail' ultérieurement. :p\n".red
			# récup mentions dans le post
			# formatte le post avec @username au début suivi des autres @mentionnés !
			status = ClientStatus.new
			puts status.writePost()
			client = AyaDN::AppdotnetSendPost.new(@token)
			puts client.composePost(postID)
		end
	end
end