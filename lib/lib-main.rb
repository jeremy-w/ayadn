#!/usr/bin/ruby
# encoding: utf-8
class AyaDN
	def initialize(token)
		@token = token
		@api = AyaDN::API.new(@token)
		@status = ClientStatus.new
	end

	def stream
	 	puts AyaDN::View.new(@hash).showStream
	end
	def checkinsStream
	    puts AyaDN::View.new(@hash).showCheckinsStream
	end
	def ayadnGlobal
		puts @status.getGlobal
		@hash = @api.getGlobal
		stream
	end
	def ayadnUnified
		puts @status.getUnified
		@hash = @api.getUnified
		stream
	end
	def ayadnHashtags(tag)
		puts @status.getHashtags(tag)
		@hash = @api.getHashtags(tag)
		stream
	end
	def ayadnExplore(explore)
		puts @status.getExplore(explore)
		@hash = @api.getExplore(explore)
		if explore == "checkins"
			checkinsStream
		else
			stream
		end
	end
	def ayadnUserMentions(name)
		puts @status.mentionsUser(name)
		@hash = @api.getUserMentions(name)
		stream
	end
	def ayadnUserPosts(name)
		puts @status.postsUser(name)
		@hash = @api.getUserPosts(name)
		stream
	end
	def ayadnUserInfos(name)
		puts @status.infosUser(name)
		@hash = @api.getUserInfos(name)
	    puts AyaDN::View.new(@hash).showUsersInfos(name)
	end
	def ayadnWhoReposted(postID)
		puts @status.whoReposted(postID)
		@hash = @api.getWhoReposted(postID)
		if @hash.empty?
			puts "\nThis post hasn't been reposted by anyone.\n\n".red
			exit
		end
	    puts AyaDN::View.new(@hash).showUsersList()
	end
	def ayadnWhoStarred(postID)
		puts @status.whoStarred(postID)
		@hash = @api.getWhoStarred(postID)
		if @hash.empty?
			puts "\nThis post hasn't been starred by anyone.\n\n".red
			exit
		end
	    puts AyaDN::View.new(@hash).showUsersList()
	end
	def ayadnStarredPosts(name)
		puts @status.starsUser(name)
		@hash = @api.getStarredPosts(name)
		stream
	end
	def ayadnConversation(postID)
		puts @status.getPostReplies(postID)
		@hash = @api.getPostReplies(postID)
		stream
	end
	def ayadnPostInfos(action, postID)
		puts @status.infosPost(postID)
		@hash = @api.getPostInfos(action, postID)
	    puts AyaDN::View.new(@hash).showPostInfos(postID)
	end
	def ayadnSendPost(text, reply_to = nil)
		if text.empty? or text == nil
			puts @status.emptyPost
			exit
		end
		puts @status.sendPost
		callback = @api.httpSend(text, reply_to)
		blob = JSON.parse(callback)
		@hash = blob['data']
		puts AyaDN::View.new(@hash).buildPostInfo(@hash)
		puts @status.postSent
	end
	def ayadnComposePost(reply_to = "", mentionsList = "", myUsername = "")
		puts @status.writePost
		$stdout.sync = true
		maxChar = 256
		charCount = maxChar - mentionsList.length
		text = mentionsList
		if !mentionsList.empty?
			text += " "
			charCount -= 1
		end
		print "\n\r#{charCount}".brown + " -> " + "#{text}"
		while charCount >= 0
			input = STDIN.getch
			text += input
			charCount -= 1
			print "\r#{charCount}".brown + " -> ".green + "#{text}"
			if input == "\r"
				#si touche entrée
				puts "\n\n"
				ayadnSendPost(text, reply_to)
				exit
			elsif input == "\e"
				#si touche echapp
				abort("\n\nCanceled.".reverse_color + " Your post hasn't been sent.\n\n".red)
			elsif input == "\177"
				#backspace counts as 1 character as well
				text = text[0...-2]
				charCount += 2
				print "\n\r#{charCount}".brown + " -> ".green + "#{text}"
			#elsif 
				#fleches clavier et autres touches à ignorer	
			end
		end
		puts "error maxchars"
		exit
	end
	def ayadnReply(postID)
		puts "Replying to post ".cyan + "#{postID}...\n".brown
		puts "Extracting mentions...\n".cyan
		rawMentionsText, replyingToThisUsername, isRepost = @api.getPostMentions(postID)
		if isRepost != nil
			puts "This post is a repost. Please reply to the parent post.\n\n".red
			exit
		end
		content = Array.new
		splitted = rawMentionsText.split(" ")
		splitted.each do |word|
			if word =~ /^@/
				content.push(word)
			end
		end
		# detecte si mentions contiennent soi-même
		myUsername = @api.getUserName("me")
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
		ayadnComposePost(postID, mentionsList)
	end
	def ayadnDeletePost(postID)
		puts @status.deletePost(postID)
		isTherePost, isYours = @api.goDelete(postID)
		if isTherePost == nil
			puts "\nPost already deleted.\n\n".red
		else
			@api.restDelete()
			puts "\nPost successfully deleted.\n\n".green
			exit
		end
	end
	def ayadnGetFollowingList(name)
		beforeID = nil
		globArray = []
		@hash = @api.getFollowings(name, beforeID)
	    usersArray, pagination_array = AyaDN::View.new(@hash).buildFollowingList()
	    globArray.push(usersArray)
	    beforeID = pagination_array.last
		while pagination_array != nil
			@hash = @api.getFollowings(name, beforeID)
		    usersArray, pagination_array = AyaDN::View.new(@hash).buildFollowingList()
		    globArray.push(usersArray)
	    	break if pagination_array.first == nil
	    	beforeID = pagination_array.last
		end
	    return globArray
	end
	def ayadnSaveFollowingList(name)
		puts "Fetching ".cyan + "#{name}".brown + "'s list of followings.\n".cyan
		puts "Please wait...\n".green
		home = Dir.home
		ayadn_root_path = home + "/.ayadn"
		ayadn_data_path = ayadn_root_path + "/data"
		ayadn_lists_path = ayadn_data_path + "/lists/"
		file = "#{name}.following"
		fileURL = ayadn_lists_path + file
		unless Dir.exists?ayadn_lists_path
			puts "Creating lists directory in ".green + "#{ayadn_data_path}".brown + "\n"
			FileUtils.mkdir_p ayadn_lists_path
		end
		if File.exists?(fileURL)
			puts "\nYou already saved this list.\n\n".red
			exit
			# option pour écraser
		end
		followingList = ayadnGetFollowingList(name)
		puts "Saving the list...\n".green
		puts followingList.join("  ").brown
		f = File.new(fileURL, "w")
			f.puts(followingList)
		f.close
		puts "\nSuccessfully saved the list.\n\n".green
		exit
	end
	def ayadnSavePost(postID)
		name = postID.to_s
		home = Dir.home
		ayadn_root_path = home + "/.ayadn"
		ayadn_data_path = ayadn_root_path + "/data"
		ayadn_posts_path = ayadn_data_path + "/posts/"
		unless Dir.exists?ayadn_posts_path
			puts "Creating posts directory in ".green + "#{ayadn_posts_path}...".brown
			FileUtils.mkdir_p ayadn_posts_path
		end
		file = "#{name}.post"
		fileURL = ayadn_posts_path + file
		if File.exists?(fileURL)
			puts "\nYou already saved this post.\n\n".red
			exit
		end
		puts "\nLoading post ".green + "#{postID}".brown
		@hash = @api.getSinglePost(postID)
		puts @status.savingFile(name, ayadn_posts_path, file)
		f = File.new(fileURL, "w")
			f.puts(@hash)
		f.close
		puts "\nSuccessfully saved the post.\n\n".green
		exit
	end

	# will be used in many places
	def ayadnGetOriginalPost(postID)
		originalPostID = @api.getOriginalPost(postID)
	end
	#

	def ayadnFollowing(action, name)
		youFollow, followsYou = @api.getUserFollowInfo(name)
		if action == "follow"
			if youFollow == true
				puts "You're already following this user.\n\n".red
				exit
			else
				resp = @api.followUser(name)
				puts "\nYou just followed user ".green + "#{name}".brown + "\n\n"
			end
		elsif action == "unfollow"
			if youFollow == false
				puts "You're already not following this user.\n\n".red
				exit
			else
				resp = @api.unfollowUser(name)
				puts "\nYou just unfollowed user ".green + "#{name}".brown + "\n\n"
			end
		else
			puts "\nsyntax error\n"
		end
	end
	def ayadnStarringPost(action, postID)
		@hash = @api.getSinglePost(postID)
		postInfo = @hash['data']
		youStarred = postInfo['you_starred']
		isRepost = postInfo['repost_of']
		if isRepost != nil
			# todo: implement automatic get original post
			puts "\nThis post is a repost. Please star the parent post.\n\n".red
			exit
		end
		if action == "star"
			if youStarred == false
				puts "\nStarring post ".green + "#{postID}\n".brown
				resp = @api.starPost(postID)
				puts "\nSuccessfully starred the post.\n\n".green
			else
				puts "Canceled: the post is already starred.\n\n".red
				exit
			end
		elsif action == "unstar"
			if youStarred == false
				puts "Canceled: the post wasn't already starred.\n\n".red
				exit
			end
			puts "\nUnstarring post ".green + "#{postID}\n".brown
			resp = @api.unstarPost(postID)
			puts "\nSuccessfully unstarred the post.\n\n".green
		else
			puts "\nsyntax error\n".red
		end
	end
	def ayadnReposting(action, postID)
		@hash = @api.getSinglePost(postID)
		postInfo = @hash['data']
		isRepost = postInfo['repost_of']
		youReposted = postInfo['you_reposted']
		if isRepost != nil
			# todo: implement automatic get original post
			puts "\nThis post is a repost. Please star the parent post.\n\n".red
			exit
		end
		if action == "repost"
			if youReposted == false
				puts "\nReposting post ".green + "#{postID}\n".brown
				resp = @api.repostPost(postID)
				puts "\nSuccessfully reposted the post.\n\n".green
			else
				puts "Canceled: you already reposted this post.\n\n".red
				exit
			end
		elsif action == "unrepost"
			if youReposted == true
				puts "\nUnreposting post ".green + "#{postID}\n".brown
				resp = @api.unrepostPost(postID)
				puts "\nSuccessfully unreposted the post.\n\n".green
			else
				puts "Canceled: this post wasn't reposted.\n\n".red
				exit
			end
		else
			puts "\nsyntax error\n".red
		end
	end
end













