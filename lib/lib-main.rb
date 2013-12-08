#!/usr/bin/ruby
# encoding: utf-8
class AyaDN
	def initialize(token)
		@token = token
		@api = AyaDN::API.new(@token)
		@view = AyaDN::View
	end
	def stream
		$tools.fileOps("makedir", $ayadn_last_page_ID_path)
	 	puts @view.new(@hash).showStream
	end
	def completeStream
		$tools.fileOps("makedir", $ayadn_last_page_ID_path)
	    stream, pagination_array = @view.new(@hash).showCompleteStream
	    last_page_ID = pagination_array.last
		return stream, last_page_ID
	end
	def debugStream
		puts @view.new(@hash).showDebugStream
	end
	def ayadnDebugStream
		@hash = @api.getUnified
		debugStream
	end
	def ayadnDebugPost(postID)
		@hash = @api.getPostInfos("call", postID)
		debugStream
	end
	def ayadnDebugMessage(channel_id, message_id)
		@hash = @api.getUniqueMessage(channel_id, message_id)
		debugStream
	end

	def ayadnAuthorize(action)
		$tools.fileOps("makedir", $ayadn_authorization_path)
		if action == "reset"
			$tools.fileOps("reset", "credentials")
		end
		auth_token = $tools.fileOps("auth", "read")
		if auth_token == nil
			url = @api.makeAuthorizeURL
			case RbConfig::CONFIG['host_os']
			when /mswin|mingw|mingw32|cygwin/
				puts $status.launchAuthorization("win")
			when /linux/
				puts $status.launchAuthorization("linux")
			else
				puts $status.launchAuthorization("osx")
				$tools.startBrowser(url)
			end
			auth_token = STDIN.gets.chomp()
			$tools.fileOps("auth", "write", auth_token)
			puts $status.authorized
			sleep 3
			puts $tools.helpScreen
			puts "Enjoy!\n".cyan
		end
	end

	def displayStream(stream)
		!stream.empty? ? (puts stream) : (puts $status.noNewPosts)
	end
	def displayScrollStream(stream)
		!stream.empty? ? (puts stream) : (print "\r")
	end
	def ayadnScroll(value, target)
		value = "unified" if value == nil
		if target == nil
			fileURL = $ayadn_last_page_ID_path + "/last_page_ID-#{value}"
		else
			fileURL = $ayadn_last_page_ID_path + "/last_page_ID-#{value}-#{target}"
		end
		loop do
			begin
				print "\r                                         \r"
				last_page_ID = $tools.fileOps("getlastpageid", fileURL)
				case value
				when "global"
					@hash = @api.getGlobal(last_page_ID)
				when "unified"
					@hash = @api.getUnified(last_page_ID)
				when "checkins", "photos", "conversations", "trending"
					@hash = @api.getExplore(value, last_page_ID)
				when "mentions"
					@hash = @api.getUserMentions(target, last_page_ID)
				when "posts"
					@hash = @api.getUserPosts(target, last_page_ID)
				end
				# todo: color post id if I'm mentioned
				stream, last_page_ID = completeStream
				displayScrollStream(stream)
				if last_page_ID != nil
					$tools.fileOps("writelastpageid", fileURL, last_page_ID)
					print "\r                                         "
            		puts "\n\n"
            		$tools.countdown($countdown_1)
            	else
        			print "\rNo new posts                ".red
        			sleep 2
        			$tools.countdown($countdown_2)
        		end					
			rescue Exception => e
				abort($status.stopped)
			end
		end
	end
	def ayadnInteractions
		puts $status.getInteractions
		#$tools.fileOps("makedir", $ayadn_last_page_ID_path)
		#fileURL = $ayadn_last_page_ID_path + "/last_page_ID-interactions"
		#last_page_ID = $tools.fileOps("getlastpageid", fileURL)
		@hash = @api.getInteractions
		#$tools.fileOps("writelastpageid", fileURL, last_page_ID) unless last_page_ID == nil
		stream, last_page_ID = @view.new(@hash).showInteractions
		puts stream + "\n\n"
	end
	def ayadnGlobal
		puts $status.getGlobal
		fileURL = $ayadn_last_page_ID_path + "/last_page_ID-global"
		last_page_ID = $tools.fileOps("getlastpageid", fileURL)
		@hash = @api.getGlobal(last_page_ID)
		stream, last_page_ID = completeStream
		$tools.fileOps("writelastpageid", fileURL, last_page_ID) unless last_page_ID == nil
		displayStream(stream)
	end
	def ayadnUnified
		fileURL = $ayadn_last_page_ID_path + "/last_page_ID-unified"
		last_page_ID = $tools.fileOps("getlastpageid", fileURL)
		puts $status.getUnified
		@hash = @api.getUnified(last_page_ID)
		stream, last_page_ID = completeStream
		$tools.fileOps("writelastpageid", fileURL, last_page_ID) unless last_page_ID == nil
		displayStream(stream)
	end
	def ayadnHashtags(tag)
		puts $status.getHashtags(tag)
		@hash = @api.getHashtags(tag)
		stream, last_page_ID = completeStream
		displayStream(stream)
	end
	def ayadnExplore(explore)
		fileURL = $ayadn_last_page_ID_path + "/last_page_ID-#{explore}"
		last_page_ID = $tools.fileOps("getlastpageid", fileURL)
		puts $status.getExplore(explore)
		@hash = @api.getExplore(explore, last_page_ID)
		stream, last_page_ID = completeStream
		$tools.fileOps("writelastpageid", fileURL, last_page_ID) unless last_page_ID == nil
		displayStream(stream)
	end
	def ayadnUserMentions(name)
		fileURL = $ayadn_last_page_ID_path + "/last_page_ID-mentions-#{name}"
		last_page_ID = $tools.fileOps("getlastpageid", fileURL)
		puts $status.mentionsUser(name)
		@hash = @api.getUserMentions(name, last_page_ID)
		stream, last_page_ID = completeStream
		$tools.fileOps("writelastpageid", fileURL, last_page_ID) unless last_page_ID == nil
		displayStream(stream)
	end
	def ayadnUserPosts(name)
		fileURL = $ayadn_last_page_ID_path + "/last_page_ID-posts-#{name}"
		last_page_ID = $tools.fileOps("getlastpageid", fileURL)
		puts $status.postsUser(name)
		@hash = @api.getUserPosts(name, last_page_ID)
		stream, last_page_ID = completeStream
		$tools.fileOps("writelastpageid", fileURL, last_page_ID) unless last_page_ID == nil
		displayStream(stream)
	end
	def ayadnUserInfos(name)
		puts $status.infosUser(name)
		@hash = @api.getUserInfos(name)
	    puts @view.new(@hash).showUsersInfos(name)
	end
	
	def ayadnSendMessage(target, text)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendMessage
		callback = @api.httpSendMessage(target, text)
		blob = JSON.parse(callback)
		@hash = blob['data']
		private_message_channel_ID = @hash['channel_id']
		private_message_thread_ID = @hash['thread_id']
		private_message_ID = @hash['id']
		$tools.fileOps("makedir", $ayadn_messages_path)
		puts "Channel ID: ".cyan + private_message_channel_ID.brown + " Message ID: ".cyan + private_message_ID.brown + "\n\n"
		puts $status.postSent
		$tools.fileOps("savechannelid", private_message_channel_ID, target)
	end
	def ayadnGetMessages(target, action = nil)
		if target != nil
			fileURL = $ayadn_last_page_ID_path + "/last_page_ID-channels-#{target}"
			last_page_ID = $tools.fileOps("getlastpageid", fileURL) unless action == "all"
			@hash = @api.getMessages(target, last_page_ID)
			messages_string, last_page_ID = @view.new(@hash).showMessagesFromChannel
			$tools.fileOps("writelastpageid", fileURL, last_page_ID) unless last_page_ID == nil
			displayStream(messages_string)
		else
			loaded_channels = $tools.fileOps("loadchannels", nil)
			if loaded_channels != nil
				puts "Backed-up list of your active channels:\n".green
				loaded_channels.each do |k,v|
					puts "Channel: ".cyan + k.brown
					puts "Interlocutor: ".cyan + v.magenta
					puts "\n"
				end
				puts "Do you want to see if you have more channels activated? (Y/n)".green
				input = STDIN.getch
				abort("\nCanceled.\n\n".red) unless input == ("y" || "Y")
				puts "\n"
			end
			@hash = @api.getChannels
			the_channels, channels_list = @view.new(@hash).showChannels
			if $drafts != nil
				private_message_channel_ID = $drafts
				$tools.fileOps("savechannelid", private_message_channel_ID, "drafts")
			end
			puts the_channels
		end
	end

	def ayadnSendPost(text, reply_to = nil)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendPost
		callback = @api.httpSend(text, reply_to)
		blob = JSON.parse(callback)
		@hash = blob['data']
		my_post_id = @hash['id']
		puts @view.new(@hash).buildPostInfo(@hash, isMine = true)
		puts $status.postSent
		# show end of the stream after posting
		if reply_to.empty?
			@hash = @api.getSimpleUnified
			stream, last_page_ID = completeStream
			displayStream(stream)
		else
			hash1 = @api.getPostReplies(reply_to)
			hash_data = hash1['data']
			last_of_hash = hash_data.last
			original_post = @view.new(nil).buildSimplePost(last_of_hash)
			hash2 = @api.getSimpleUnified
			unified_data = hash2['data']
			first_of_unified = unified_data.last # because adnData.reverse in API
			first_of_unified_id = first_of_unified['id']
			if first_of_unified_id.to_i > reply_to.to_i
				puts original_post
			end
			@hash = hash1.merge!(hash2)
			stream, last_page_ID = completeStream
			stream.sub!(/#{reply_to}/, reply_to.to_s.red.reverse_color) if first_of_unified_id.to_i < reply_to.to_i
			stream.sub!(/#{my_post_id}/, my_post_id.to_s.green.reverse_color)
			displayStream(stream)
		end
	end
	def ayadnComposeMessage(target)
		puts $status.writeMessage
		max_char = 2048
		begin
			input_text = STDIN.gets.chomp
		rescue Exception => e
			abort($status.errorMessageNotSent)
		end
		to_regex = input_text.dup
		without_markdown = $tools.getMarkdownText(to_regex)
		real_length = without_markdown.length
		if real_length < 2048
			ayadnSendMessage(target, input_text)
		else
			to_remove = real_length - max_char
			abort($status.errorMessageTooLong(real_length, to_remove))
		end
	end
	def ayadnComposePost(reply_to = "", mentions_list = "", my_username = "")
		puts $status.writePost
		max_char = 256
		char_count = max_char - mentions_list.length
		# be careful to not color escape mentions_list or text
		text = mentions_list
		if !mentions_list.empty?
			text += " "
			char_count -= 1
		end
		print "\n#{text}"
		begin
			input_text = STDIN.gets.chomp
		rescue Exception => e
			abort($status.errorPostNotSent)
		end
		post_text = text + input_text
		to_regex = post_text.dup
		without_markdown = $tools.getMarkdownText(to_regex)
		total_length = char_count - without_markdown.length
		real_length = max_char + total_length.abs
		if total_length > 0
			ayadnSendPost(post_text, reply_to)
		else
			to_remove = real_length - max_char
			abort($status.errorPostTooLong(real_length, to_remove))
		end
	end
	def ayadnReply(postID)
		puts $status.replyingToPost(postID)
		post_mentions_array, replying_to_this_username, is_repost = @api.getPostMentions(postID) 
		if is_repost != nil
			puts $status.errorIsRepost(postID)
			postID = is_repost['id']
			puts $status.redirectingToOriginal(postID)
			post_mentions_array, replying_to_this_username, is_repost = @api.getPostMentions(postID) 
		end
		my_username = @api.getUserName("me")
		#my_handle = "@" + my_username
		replying_to_handle = "@" + replying_to_this_username
		new_content = Array.new
		# if I'm not answering myself, add the @username of the "replyee"
		new_content.push(replying_to_handle) if replying_to_this_username != my_username 
		post_mentions_array.each do |item|
			# if I'm in the post's mentions, erase me, else insert the mention
			if item != my_username
				new_content.push("@" + item)
			end
		end
		mentions_list = new_content.join(" ")
		ayadnComposePost(postID, mentions_list)
	end
	def ayadnDeletePost(postID)
		puts $status.deletePost(postID)
		is_there_post, is_yours = @api.goDelete(postID)
		if is_there_post == nil
			abort($status.errorAlreadyDeleted)
		else
			@api.restDelete()
			puts $status.postDeleted
			exit
		end
	end
	def ayadnDeactivateChannel(channel_id)
 		resp = @api.deactivateChannel(channel_id)
 		puts resp
 	end
	def ayadnWhoReposted(postID)
		puts $status.whoReposted(postID)
		@hash = @api.getWhoReposted(postID)
		abort($status.errorNobodyReposted) if @hash['data'].empty?
	    puts @view.new(@hash).showUsersList()
	end
	def ayadnWhoStarred(postID)
		puts $status.whoStarred(postID)
		@hash = @api.getWhoStarred(postID)
		abort($status.errorNobodyStarred) if @hash['data'].empty?
	    puts @view.new(@hash).showUsersList()
	end
	def ayadnStarredPosts(name)
		puts $status.starsUser(name)
		@hash = @api.getStarredPosts(name)
		stream, last_page_ID = completeStream
		displayStream(stream)
	end
	def ayadnConversation(postID)
		puts $status.getPostReplies(postID)
		@hash = @api.getPostReplies(postID)
		stream, last_page_ID = completeStream
		displayStream(stream)
	end
	def ayadnPostInfos(action, postID)
		puts $status.infosPost(postID)
		@hash = @api.getPostInfos(action, postID)
	    puts @view.new(@hash).showPostInfos(postID, isMine = false)
	end
	def getList(list, name)
		beforeID = nil
		big_hash = {}
		if list == "followers"
			@hash = @api.getFollowers(name, beforeID)
		elsif list == "followings"
			@hash = @api.getFollowings(name, beforeID)
		elsif list == "muted"
			@hash = @api.getMuted(name, beforeID)
		end
		users_hash, pagination_array = @view.new(@hash).buildFollowList()
	    big_hash.merge!(users_hash)
	    beforeID = pagination_array.last
	    while pagination_array != nil
			if list == "followers"
				@hash = @api.getFollowers(name, beforeID)
			elsif list == "followings"
				@hash = @api.getFollowings(name, beforeID)
			elsif list == "muted"
				@hash = @api.getMuted(name, beforeID)
			end
		    users_hash, pagination_array = @view.new(@hash).buildFollowList()
		    big_hash.merge!(users_hash)
	    	break if pagination_array.first == nil
	    	beforeID = pagination_array.last
		end
	    return big_hash
	end

	def ayadnShowList(list, name)
		puts $status.fetchingList(list)
		@hash = getList(list, name)
		if list == "muted"
			puts "Your list of muted users:\n".green
		elsif list == "followings"
			puts "List of users you're following:\n".green
		elsif list == "followers"
			puts "List of users following you:\n".green
		end
		users, number = @view.new(@hash).showUsers()
		puts users
		puts "Number of users: ".green + " #{number}\n".brown
	end

	def ayadnSaveList(list, name) # to be called with: var = ayadnSaveList("followers", "@ericd")
		file = "/#{name}-#{list}.json"
		fileURL = $ayadn_lists_path + file
		unless Dir.exists?$ayadn_lists_path
			puts "Creating lists directory in ".green + "#{$ayadn_data_path}".brown + "\n"
			FileUtils.mkdir_p $ayadn_lists_path
		end
		if File.exists?(fileURL)
			puts "\nYou already saved this list.\n".red
			puts "Delete the old one and replace with this one? (n/y)\n".red
			input = STDIN.getch
			abort("\nCanceled.\n\n".red) unless input == ("y" || "Y")
		end
		if list == "muted"
			puts "\nFetching your muted users list.\n".cyan
		else
			puts "\nFetching ".cyan + "#{name}".brown + "'s list of #{list}.\n".cyan
		end
		puts "Please wait...\n".green
		follow_list = getList(list, name)
		puts "Saving the list...\n".green
		f = File.new(fileURL, "w")
			f.puts(follow_list.to_json)
		f.close
		puts "\nSuccessfully saved the list.\n\n".green
		exit
	end

	def ayadnSavePost(postID)
		name = postID.to_s
		unless Dir.exists?$ayadn_posts_path
			puts "Creating posts directory in ".green + "#{$ayadn_data_path}...".brown
			FileUtils.mkdir_p $ayadn_posts_path
		end
		file = "/#{name}.post"
		fileURL = $ayadn_posts_path + file
		if File.exists?(fileURL)
			abort("\nYou already saved this post.\n\n".red)
		end
		puts "\nLoading post ".green + "#{postID}".brown
		@hash = @api.getSinglePost(postID)
		puts $status.savingFile(name, $ayadn_posts_path, file)
		f = File.new(fileURL, "w")
			f.puts(@hash)
		f.close
		puts "\nSuccessfully saved the post.\n\n".green
		exit
	end

	# could be used in many places if needed
	def ayadnGetOriginalPost(postID)
		original_post_ID = @api.getOriginalPost(postID)
	end
	#

	def ayadnSearch(value)
		@hash = @api.getSearch(value)
		stream, last_page_ID = completeStream
		displayStream(stream)
	end

	def ayadnFollowing(action, name)
		you_follow, follows_you = @api.getUserFollowInfo(name)
		if action == "follow"
			if you_follow == true
				abort("You're already following this user.\n\n".red)
			else
				resp = @api.followUser(name)
				puts "\nYou just followed user ".green + "#{name}".brown + "\n\n"
			end
		elsif action == "unfollow"
			if you_follow == false
				abort("You're already not following this user.\n\n".red)
			else
				resp = @api.unfollowUser(name)
				puts "\nYou just unfollowed user ".green + "#{name}".brown + "\n\n"
			end
		else
			abort($status.errorSyntax)
		end
	end

	def ayadnMuting(action, name)
		you_muted = @api.getUserMuteInfo(name)
		if action == "mute"
			if you_muted == "true"
				abort("You've already muted this user.\n\n".red)
			else
				resp = @api.muteUser(name)
				puts "\nYou just muted user ".green + "#{name}".brown + "\n\n"
			end
		elsif action == "unmute"
			if you_muted == "false"
				abort("This user is not muted.\n\n".red)
			else
				resp = @api.unmuteUser(name)
				puts "\nYou just unmuted user ".green + "#{name}".brown + "\n\n"
			end
		else
			abort($status.errorSyntax)
		end
	end

	def ayadnStarringPost(action, postID)
		@hash = @api.getSinglePost(postID)
		post_data = @hash['data']
		you_starred = post_data['you_starred']
		is_repost = post_data['repost_of']
		if is_repost != nil
			puts $status.errorIsRepost(postID)
			puts "Redirecting to the original post.\n".cyan
			postID = is_repost['id']
			you_starred = is_repost['you_starred']
		end
		if action == "star"
			if you_starred == false
				puts "\nStarring post ".green + "#{postID}\n".brown
				resp = @api.starPost(postID)
				puts "\nSuccessfully starred the post.\n\n".green
			else
				abort("Canceled: the post is already starred.\n\n".red)
			end
		elsif action == "unstar"
			if you_starred == false
				abort("Canceled: the post wasn't already starred.\n\n".red)
			else
				puts "\nUnstarring post ".green + "#{postID}\n".brown
				resp = @api.unstarPost(postID)
				puts "\nSuccessfully unstarred the post.\n\n".green
			end
		else
			abort("\nsyntax error\n".red)
		end
	end
	def ayadnReposting(action, postID)
		@hash = @api.getSinglePost(postID)
		post_data = @hash['data']
		is_repost = post_data['repost_of']
		you_reposted = post_data['you_reposted']
		if is_repost != nil && you_reposted == false
			puts $status.errorIsRepost(postID)
			puts "Redirecting to the original post.\n".cyan
			postID = is_repost['id']
			you_reposted = is_repost['you_reposted']
		end
		if action == "repost"
			if you_reposted == false
				puts "\nReposting post ".green + "#{postID}\n".brown
				resp = @api.repostPost(postID)
				puts "\nSuccessfully reposted the post.\n\n".green
			else
				abort("Canceled: you already reposted this post.\n\n".red)
			end
		elsif action == "unrepost"
			if you_reposted == true
				puts "\nUnreposting post ".green + "#{postID}\n".brown
				resp = @api.unrepostPost(postID)
				puts "\nSuccessfully unreposted the post.\n\n".green
			else
				abort("Canceled: this post wasn't reposted by you.\n\n".red)
			end
		else
			abort($status.errorSyntax)
		end
	end
	def ayadnReset(target, content, option)
		$tools.fileOps("reset", target, content, option)
	end
	def ayadnSkipSource(action, source)
		puts "Current skipped sources: ".green + $skipped_sources.join(", ").red + "\n"
		if action == "add"
			puts "Adding ".green + source.red + " to the skipped sources.".green + "\n"
			$configFileContents['skipped']['sources'].each do |config_sources|
				if config_sources == source
					puts "#{source}".red + " is already skipped.\n\n".green
					exit
				end
			end
			$configFileContents['skipped']['sources'].push(source)
			puts "New skipped sources: ".green + $configFileContents['skipped']['sources'].join(", ").red + "\n\n"
			$tools.saveConfig
		elsif action == "remove"
			puts "Removing ".green + source.red + " from the skipped sources.".green + "\n"
			$configFileContents['skipped']['sources'].each do |config_sources|
				if config_sources == source
					$configFileContents['skipped']['sources'].delete(config_sources)
				end
			end
			puts "New skipped sources: ".green + $configFileContents['skipped']['sources'].join(", ").red + "\n\n"
			$tools.saveConfig
		else
			puts "Current skipped sources: ".green + $skipped_sources.join(", ").red + "\n\n"
		end
 	end

 	# experimenting
 	def ayadnFileUpload(file_name)
 		# puts "\nUploading ".green + file_name.brown + "\n"
 		# response = @api.createIncompleteFileUpload(file_name)
 		# puts response.inspect        #SUCCESS
 	end


 	def ayadnFiles(action, target, value)
 		case action
 		when "list"
			big_view = ""
 			with_url = false
 			if value == "all"
 				puts "\nGetting the list of all your files...\n".green
 				beforeID = nil
 				pagination_array = []
 				reverse = true
 				i = 1
		    	loop do
		    		@hash = @api.getFilesList(beforeID)
		    		view, file_url, pagination_array = @view.new(@hash).showFilesList(with_url, reverse)
		    		beforeID = pagination_array.last
		    		break if beforeID == nil
		    		#big_view += view
	 				puts view
	 				i += 1
		    		if pagination_array.first != nil
		    			$tools.countdown(5) unless i == 2
		    			print "\r" + (" " * 40) unless i == 2
		    			print "\n\nPlease wait, fetching page (".cyan + "#{beforeID}".pink + ")...\n".cyan unless i == 2
		    		end
				end
				puts "\n"
			else
				puts "\nGetting the list of your recent files...\n".green
				@hash = @api.getFilesList(nil)
				reverse = false
				view, file_url, pagination_array = @view.new(@hash).showFilesList(with_url, reverse)
				big_view += view
			end
 			puts big_view
 		when "download"
 			with_url = true
 			targets_array = target.split(",")
 			number_of_targets = targets_array.length
 			$tools.fileOps("makedir", $ayadn_files_path)
 			if number_of_targets == 1
	 			@hash = @api.getSingleFile(target)
	 			view, file_url, file_name = @view.new(@hash).showFileInfo(with_url)
	 			puts "\nDownloading file ".green + target.to_s.brown
	 			puts view
	 			#new_file_name = "#{target}_#{file_name}" # should put target before .ext instead
	 			new_file_name = "#{file_name}"
	 			download_file_path = $ayadn_files_path + "/#{new_file_name}"
	 			if !File.exists?download_file_path
	 				the_file = @api.getResponse(file_url)
		 			f = File.new(download_file_path, "wb")
		 				f.puts(the_file)
		 			f.close
		 			puts "File downloaded in ".green + $ayadn_files_path.pink + "/#{new_file_name}".brown + "\n\n"
		 		else
		 			puts "Canceled: ".red + "#{new_file_name} ".pink + "already exists in ".red + "#{$ayadn_files_path}".brown + "\n\n"
	 			end
	 		else
	 			@hash = @api.getMultipleFiles(target)
	 			@hash['data'].each do |unique_file|
		 			view, file_url, file_name = @view.new(nil).buildFileInfo(unique_file, with_url)
		 			unique_file_id = unique_file['id']
		 			puts "\nDownloading file ".green + unique_file_id.to_s.brown
		 			puts view
		 			new_file_name = "#{unique_file_id}_#{file_name}"
		 			download_file_path = $ayadn_files_path + "/#{new_file_name}"
		 			if !File.exists?download_file_path
		 				the_file = @api.getResponse(file_url)
			 			f = File.new(download_file_path, "wb")
			 				f.puts(the_file)
			 			f.close
			 			puts "File downloaded in ".green + $ayadn_files_path.pink + "/#{new_file_name}".brown + "\n\n"
			 		else
			 			puts "Canceled: ".red + "#{new_file_name} ".pink + "already exists in ".red + "#{$ayadn_files_path}".brown + "\n\n"
		 			end
		 		end
	 		end
	 	when "upload"
	 		case RbConfig::CONFIG['host_os']     
            when /mswin|mingw|cygwin/
            	puts "\nThis feature doesn't work on Windows yet. Sorry.\n\n".red
            	exit
            end
	 		targets_array = target.split(",")
 			number_of_targets = targets_array.length
 			$tools.fileOps("makedir", $ayadn_files_path)
 			uploaded_ids = []
 			targets_array.each do |file|
 				file_name = File.basename(file)
 				puts "Uploading ".cyan + "#{file_name}".brown + "\n\n"
 				resp = JSON.parse($tools.uploadImage(file, @token))
 				meta = resp['meta']
 				if meta['code'] == 200
 					puts "\nDone!\n".green
 				else
 					puts "\nERROR: #{meta.inspect}\n".red
 				end
 				data = resp['data']
 				new_file_id = data['id']
 				uploaded_ids.push(new_file_id)
 			end
 			@hash = @api.getFilesList(nil)
			reverse = false
			view, file_url, pagination_array = @view.new(@hash).showFilesList(with_url, reverse)
			uploaded_ids.each do |id|
				view.gsub!("#{id}", "#{id}".reverse_color)
			end
			puts view
		when "remove", "delete-file"
			puts "\nWARNING: ".red + "delete a file ONLY is you're sure it's not referenced by a post or a message.\n\n".pink
			puts "Do you wish to continue? (y/N) ".cyan
			input = STDIN.getch
			if input == ("y" || "Y")
				puts "\nPlease wait...".green
				resp = JSON.parse(@api.deleteFile(target))
				meta = resp['meta']
 				if meta['code'] == 200
 					puts "\n\nDone!\n".green
 				else
 					puts "\n\nERROR: #{meta.inspect}\n".red
 				end
			else
				puts "\n\nCanceled.\n\n".red
				exit
			end


		when "backup"
			# backup all my files locally

		when "public"
			# make private file public

		when "private"
			# make public file private

 		end
 	end
end













