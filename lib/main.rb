#!/usr/bin/env ruby
# encoding: utf-8
class AyaDN
	def initialize(token)
		@token = token
		@api = AyaDN::API.new(@token)
		@view = AyaDN::View
	end
	def stream
		$tools.files_ops("makedir", $tools.ayadn_configuration[:last_page_id_path])
	 	puts @view.new(@hash).showStream
	end
	def completeStream
		$tools.files_ops("makedir", $tools.ayadn_configuration[:last_page_id_path])
	    stream, pagination_array = @view.new(@hash).showCompleteStream
	    last_page_id = pagination_array.last
		return stream, last_page_id
	end
	def debugStream
		puts @view.new(@hash).showDebugStream
	end
	def ayadnDebugStream
		@hash = @api.getUnified(nil)
		debugStream
	end
	def ayadnDebugPost(postID)
		@hash = @api.getPostInfos("call", postID)
		debugStream
	end
	def ayadnDebugUser(username)
		@hash = @api.getUserInfos(username)
		debugStream
	end
	def ayadnDebugMessage(channel_id, message_id)
		@hash = @api.getUniqueMessage(channel_id, message_id)
		debugStream
	end

	def ayadnAuthorize(action)
		$tools.files_ops("makedir", $tools.ayadn_configuration[:authorization_path])
		if action == "reset"
			$tools.files_ops("reset", "credentials")
		end
		auth_token = $tools.files_ops("auth", "read")
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
			$tools.files_ops("auth", "write", auth_token)
			puts $status.authorized
			sleep 3
			puts $tools.helpScreen
			puts "Enjoy!\n".cyan
		end
	end

	def configAPI
		time_now = DateTime.now
		$tools.files_ops("makedir", $tools.ayadn_configuration[:API_config_path])
		file_API = $tools.ayadn_configuration[:API_config_path] + "/config.json"
		file_timer = $tools.ayadn_configuration[:API_config_path] + "/timer.json"
		if !File.exists?(file_API)
			resp = @api.getAPIConfig
			if resp['meta']['code'] == 200
				f = File.new(file_API, "w")
			    	f.puts(resp.to_json)
				f.close
			end
			hash_timer = {
				"checked" => time_now,
				"deadline" => time_now + 1
			}
			f = File.new(file_timer, "w")
			    f.puts(hash_timer.to_json)
			f.close
		else
			f = File.open(file_timer, "r")
			    hash_timer = JSON.parse(f.gets)
			f.close
			if DateTime.parse(hash_timer['deadline']) >= time_now 
				f = File.open(file_API, "r")
				    resp = JSON.parse(f.gets)
				f.close
			else
				resp = @api.getAPIConfig
				if resp['meta']['code'] == 200
					f = File.new(file_API, "w")
				    	f.puts(resp.to_json)
					f.close
				end
				hash_timer = {
					"checked" => time_now,
					"deadline" => time_now + 1
				}
				f = File.new(file_timer, "w")
				    f.puts(hash_timer.to_json)
				f.close
			end
		end
		$tools.ayadn_configuration['post_max_length'] = resp['data']['post']['text_max_length']
		$tools.ayadn_configuration['message_max_length'] = resp['data']['message']['text_max_length']
	end

	def displayStream(stream)
		!stream.empty? ? (puts stream) : (puts $status.noNewPosts)
	end
	def displayScrollStream(stream)
		!stream.empty? ? (puts stream) : (print "\r")
	end
	def ayadnScroll(value, target)
		$tools.ayadn_configuration[:progress_indicator] = true
		value = "unified" if value == nil
		if target == nil
			fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-#{value}"
		else
			fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-#{value}-#{target}"
		end
		loop do
			begin
				print "\r                                         \r"
				last_page_id = $tools.files_ops("getlastpageid", fileURL)
				case value
				when "global"
					@hash = @api.getGlobal(last_page_id)
				when "unified"
					@hash = @api.getUnified(last_page_id)
				when "checkins", "photos", "conversations", "trending"
					@hash = @api.getExplore(value, last_page_id)
				when "mentions"
					@hash = @api.getUserMentions(target, last_page_id)
				when "posts"
					@hash = @api.getUserPosts(target, last_page_id)
				end
				# todo: color post id if I'm mentioned
				stream, last_page_id = completeStream
				displayScrollStream(stream)
				$tools.ayadn_configuration[:progress_indicator] = false
				if last_page_id != nil
					$tools.files_ops("writelastpageid", fileURL, last_page_id)
					print "\r                                         "
            		puts "\n\n"
            		$tools.countdown($tools.config['timeline']['countdown_1'])
            	else
        			print "\rNo new posts                ".red
        			sleep 2
        			$tools.countdown($tools.config['timeline']['countdown_1'])
        		end					
			rescue Exception
				abort($status.stopped)
			end
		end
	end
	def ayadnInteractions
		puts $status.getInteractions
		puts @view.new(@api.getInteractions).showInteractions + "\n\n"
	end
	def ayadnGlobal
		puts $status.getGlobal
		fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-global"
		last_page_id = $tools.files_ops("getlastpageid", fileURL)
		@hash = @api.getGlobal(last_page_id)
		stream, last_page_id = completeStream
		$tools.files_ops("writelastpageid", fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUnified
		fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-unified"
		last_page_id = $tools.files_ops("getlastpageid", fileURL)
		puts $status.getUnified
		@hash = @api.getUnified(last_page_id)
		stream, last_page_id = completeStream
		$tools.files_ops("writelastpageid", fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnHashtags(tag)
		puts $status.getHashtags(tag)
		@hash = @api.getHashtags(tag)
		stream, last_page_id = completeStream
		displayStream(stream)
	end
	def ayadnExplore(explore)
		fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-#{explore}"
		last_page_id = $tools.files_ops("getlastpageid", fileURL)
		puts $status.getExplore(explore)
		@hash = @api.getExplore(explore, last_page_id)
		stream, last_page_id = completeStream
		$tools.files_ops("writelastpageid", fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUserMentions(name)
		fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-mentions-#{name}"
		last_page_id = $tools.files_ops("getlastpageid", fileURL)
		puts $status.mentionsUser(name)
		@hash = @api.getUserMentions(name, last_page_id)
		stream, last_page_id = completeStream
		$tools.files_ops("writelastpageid", fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUserPosts(name)
		fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-posts-#{name}"
		last_page_id = $tools.files_ops("getlastpageid", fileURL)
		puts $status.postsUser(name)
		@hash = @api.getUserPosts(name, last_page_id)
		stream, last_page_id = completeStream
		$tools.files_ops("writelastpageid", fileURL, last_page_id) unless last_page_id == nil
		displayStream(stream)
	end
	def ayadnUserInfos(name)
		puts $status.infosUser(name)
	    puts @view.new(@api.getUserInfos(name)).showUsersInfos(name)
	end
	def ayadnComposeMessage(target)
		puts $status.writeMessage
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorMessageNotSent)
		end
		real_length = $tools.getMarkdownText(input_text.dup).length
		if real_length < $tools.ayadn_configuration['message_max_length']
			ayadnSendMessage(target, input_text)
		else
			abort($status.errorMessageTooLong(real_length, real_length - $tools.ayadn_configuration['message_max_length']))
		end
	end
	def ayadnSendMessage(target, text)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendMessage
		blob = JSON.parse(@api.httpSendMessage(target, text))
		@hash = blob['data']
		private_message_channel_ID = @hash['channel_id']
		#private_message_thread_ID = @hash['thread_id']
		$tools.files_ops("makedir", $tools.ayadn_configuration[:messages_path])
		puts "Channel ID: ".cyan + private_message_channel_ID.brown + " Message ID: ".cyan + @hash['id'].brown + "\n\n"
		puts $status.postSent
		$tools.files_ops("savechannelid", private_message_channel_ID, target)
	end

	def ayadnComposeMessageToChannel(target)
		puts $status.writeMessage
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorMessageNotSent)
		end
		real_length = $tools.getMarkdownText(input_text.dup).length
		if real_length < $tools.ayadn_configuration['message_max_length']
			ayadnSendMessageToChannel(target, input_text)
		else
			abort($status.errorMessageTooLong(real_length, real_length - $tools.ayadn_configuration['message_max_length']))
		end
	end
	def ayadnSendMessageToChannel(target, text)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendMessage
		blob = JSON.parse(@api.httpSendMessageToChannel(target, text))
		@hash = blob['data']
		private_channel_ID = @hash['channel_id']
		#private_thread_ID = @hash['thread_id']
		$tools.files_ops("makedir", $tools.ayadn_configuration[:messages_path])
		puts "Channel ID: ".cyan + private_channel_ID.brown + " Message ID: ".cyan + @hash['id'].brown + "\n\n"
		puts $status.postSent
		$tools.files_ops("savechannelid", private_channel_ID, target)
	end
	def ayadnGetMessages(target, action = nil)
		$tools.files_ops("makedir", $tools.ayadn_configuration[:messages_path])
		$tools.ayadn_configuration[:progress_indicator] = false
		if target != nil
			fileURL = $tools.ayadn_configuration[:last_page_id_path] + "/last_page_id-channels-#{target}"
			last_page_id = $tools.files_ops("getlastpageid", fileURL) unless action == "all"
			messages_string, last_page_id = @view.new(@api.getMessages(target, last_page_id)).showMessagesFromChannel
			$tools.files_ops("writelastpageid", fileURL, last_page_id) unless last_page_id == nil
			displayStream(messages_string)
		else
			loaded_channels = $tools.files_ops("loadchannels", nil)
			if loaded_channels != nil
				puts "Backed-up list of your active channels:\n".green
				loaded_channels.each do |k,v|
					puts "Channel: ".cyan + k.brown
					puts "Title: ".cyan + v.magenta
					puts "\n"
				end
				puts "Do you want to see if you have more channels activated? (Y/n)".green
				abort("\nCanceled.\n\n".red) unless STDIN.getch == ("y" || "Y")
				puts "\n"
			end
			@hash = @api.getChannels
			the_channels, channels_list = @view.new(@hash).showChannels("net.app.core.pm")
			puts the_channels
			the_channels, channels_list = @view.new(@hash).showChannels(nil)
			puts the_channels
		end
	end



	def ayadnSendPost(text, reply_to = nil)
		abort($status.emptyPost) if (text.empty? || text == nil)
		puts $status.sendPost
		blob = JSON.parse(@api.httpSend(text, reply_to))
		@hash = blob['data']
		my_post_id = @hash['id']
		puts @view.new(nil).buildSimplePostInfo(@hash)
		puts $status.postSent
		# show end of the stream after posting
		if reply_to.empty?
			$tools.ayadn_configuration[:progress_indicator] = false
			@hash = @api.getSimpleUnified
			stream, last_page_id = completeStream
			displayStream(stream)
		else
			$tools.ayadn_configuration[:progress_indicator] = true
			@reply_to = reply_to
			t1 = Thread.new{@api.getPostReplies(@reply_to)}
			t2 = Thread.new{@api.getSimpleUnified}
			t1.join
			t2.join
			hash1 = t1.value
			hash2 = t2.value
			first_of_unified = hash2['data'].last # because adnData.reverse in API
			first_of_unified_id = first_of_unified['id']
			if first_of_unified_id.to_i > reply_to.to_i
				puts @view.new(nil).buildSimplePost(hash1['data'])
			end
			@hash = hash1.merge!(hash2)
			stream, last_page_id = completeStream
			stream.sub!(/#{reply_to}/, reply_to.to_s.red.reverse_color) if first_of_unified_id.to_i < reply_to.to_i
			stream.sub!(/#{my_post_id}/, my_post_id.to_s.green.reverse_color)
			displayStream(stream)
		end
	end


	def ayadnComposePost(reply_to = "", mentions_list = "", my_username = "")
		puts $status.writePost
		char_count = $tools.ayadn_configuration['post_max_length'] - mentions_list.length
		# be careful to not color escape mentions_list or text
		text = mentions_list
		if !mentions_list.empty?
			text += " "
			char_count -= 1
		end
		print "\n#{text}"
		begin
			input_text = STDIN.gets.chomp
		rescue Exception
			abort($status.errorPostNotSent)
		end
		post_text = text + input_text
		total_length = char_count - $tools.getMarkdownText(post_text.dup).length
		real_length = $tools.ayadn_configuration['post_max_length'] + total_length.abs
		if total_length > 0
			ayadnSendPost(post_text, reply_to)
		else
			abort($status.errorPostTooLong(real_length, real_length - $tools.ayadn_configuration['post_max_length']))
		end
	end
	def ayadnReply(postID)
		$tools.ayadn_configuration[:progress_indicator] = false
		puts $status.replyingToPost(postID)
		post_mentions_array, replying_to_this_username, is_repost = @api.getPostMentions(postID) 
		if is_repost != nil
			puts $status.errorIsRepost(postID)
			postID = is_repost['id']
			puts $status.redirectingToOriginal(postID)
			post_mentions_array, replying_to_this_username, is_repost = @api.getPostMentions(postID) 
		end
		if $tools.config['identity']['prefix'] == "me"
			my_username = @api.getUserName("me")
		else
			my_username = $tools.config['identity']['prefix']
		end
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
		ayadnComposePost(postID, new_content.join(" "))
	end
	def ayadnDeletePost(postID)
		puts $status.deletePost(postID)
		if @api.goDelete(postID) == nil
			abort($status.errorAlreadyDeleted)
		else
			$tools.checkHTTPResp(@api.clientHTTP("delete"))
			puts $status.postDeleted
			exit
		end
	end
	# def ayadnDeactivateChannel(channel_id)
 # 		resp = @api.deactivateChannel(channel_id)
 # 		puts resp
 # 	end
	def ayadnWhoReposted(postID)
		puts $status.whoReposted(postID)
		@hash = @api.getWhoReposted(postID)
		abort($status.errorNobodyReposted) if @hash['data'].empty?
	    puts @view.new(@hash).showUsersList
	end
	def ayadnWhoStarred(postID)
		puts $status.whoStarred(postID)
		@hash = @api.getWhoStarred(postID)
		abort($status.errorNobodyStarred) if @hash['data'].empty?
	    puts @view.new(@hash).showUsersList
	end
	def ayadnStarredPosts(name)
		puts $status.starsUser(name)
		@hash = @api.getStarredPosts(name)
		stream, last_page_id = completeStream
		displayStream(stream)
	end
	def ayadnConversation(postID)
		puts $status.getPostReplies(postID)
		@hash = @api.getPostReplies(postID)
		stream, last_page_id = completeStream
		displayStream(stream)
	end
	def ayadnPostInfos(action, postID)
		puts $status.infosPost(postID)
	    puts @view.new(@api.getPostInfos(action, postID)).showPostInfos(postID, isMine = false)
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
		users_hash, min_id = @view.new(@hash).buildFollowList
	    big_hash.merge!(users_hash)
	    beforeID = min_id
	    loop do
			if list == "followers"
				@hash = @api.getFollowers(name, beforeID)
			elsif list == "followings"
				@hash = @api.getFollowings(name, beforeID)
			elsif list == "muted"
				@hash = @api.getMuted(name, beforeID)
			end
		    users_hash, min_id = @view.new(@hash).buildFollowList
		    big_hash.merge!(users_hash)
	    	break if min_id == nil
	    	beforeID = min_id
		end
	    return big_hash
	end

	def ayadnShowList(list, name)
		$tools.ayadn_configuration[:progress_indicator] = false
		puts $status.fetchingList(list)
		puts $status.showList(list, name)
		users, number = @view.new(getList(list, name)).showUsers
		if number == 0
			puts $status.errorEmptyList
			exit
		end
		puts users
		puts "Number of users: ".green + " #{number}\n\n".brown
	end

	def ayadnSaveList(list, name) # to be called with: var = ayadnSaveList("followers", "@ericd")
		$tools.ayadn_configuration[:progress_indicator] = false
		fileURL = $tools.ayadn_configuration[:lists_path] + "/#{name}-#{list}.json"
		unless Dir.exists?$tools.ayadn_configuration[:lists_path]
			puts "Creating lists directory in ".green + "#{$tools.ayadn_configuration[:data_path]}".brown + "\n"
			FileUtils.mkdir_p $tools.ayadn_configuration[:lists_path]
		end
		if File.exists?(fileURL)
			puts "\nYou already saved this list.\n".red
			puts "Delete the old one and replace with this one? (n/y)\n".red
			abort("\nCanceled.\n\n".red) unless STDIN.getch == ("y" || "Y")
		end
		puts $status.showList(list, name)
		puts "Please wait...\n".green
		puts "Saving the list...\n".green
		f = File.new(fileURL, "w")
			f.puts(getList(list, name).to_json)
		f.close
		puts "\nSuccessfully saved the list.\n\n".green
		exit
	end

	def ayadnSavePost(postID)
		$tools.ayadn_configuration[:progress_indicator] = false
		name = postID.to_s
		unless Dir.exists?$tools.ayadn_configuration[:posts_path]
			puts "Creating posts directory in ".green + "#{$tools.ayadn_configuration[:data_path]}...".brown
			FileUtils.mkdir_p $tools.ayadn_configuration[:posts_path]
		end
		file = "/#{name}.post"
		fileURL = $tools.ayadn_configuration[:posts_path] + file
		if File.exists?(fileURL)
			abort("\nYou already saved this post.\n\n".red)
		end
		puts "\nLoading post ".green + "#{postID}".brown
		puts $status.savingFile(name, $tools.ayadn_configuration[:posts_path], file)
		f = File.new(fileURL, "w")
			f.puts(@api.getSinglePost(postID))
		f.close
		puts "\nSuccessfully saved the post.\n\n".green
		exit
	end

	# could be used in many places if needed
	# def ayadnGetOriginalPost(postID)
	# 	$tools.ayadn_configuration[:progress_indicator] = false
	# 	original_post_ID = @api.getOriginalPost(postID)
	# end
	#

	def ayadnSearch(value)
		@hash = @api.getSearch(value)
		stream, last_page_id = completeStream
		displayStream(stream)
	end

	def ayadnFollowing(action, name)
		$tools.ayadn_configuration[:progress_indicator] = false
		you_follow, follows_you = @api.getUserFollowInfo(name)
		if action == "follow"
			if you_follow
				abort("You're already following this user.\n\n".red)
			else
				@api.followUser(name)
				puts "\nYou just followed user ".green + "#{name}".brown + "\n\n"
			end
		elsif action == "unfollow"
			if you_follow
				@api.unfollowUser(name)
				puts "\nYou just unfollowed user ".green + "#{name}".brown + "\n\n"
			else
				abort("You're already not following this user.\n\n".red)
			end
		else
			abort($status.errorSyntax)
		end
	end

	def ayadnMuting(action, name)
		$tools.ayadn_configuration[:progress_indicator] = false
		you_muted = @api.getUserMuteInfo(name)
		if action == "mute"
			if you_muted
				abort("You've already muted this user.\n\n".red)
			else
				@api.muteUser(name)
				puts "\nYou just muted user ".green + "#{name}".brown + "\n\n"
			end
		elsif action == "unmute"
			if you_muted
				@api.unmuteUser(name)
				puts "\nYou just unmuted user ".green + "#{name}".brown + "\n\n"
			else
				abort("This user is not muted.\n\n".red)
			end
		else
			abort($status.errorSyntax)
		end
	end

	def ayadnStarringPost(action, postID)
		$tools.ayadn_configuration[:progress_indicator] = false
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
				@api.starPost(postID)
				puts "\nSuccessfully starred the post.\n\n".green
			else
				abort("Canceled: the post is already starred.\n\n".red)
			end
		elsif action == "unstar"
			if you_starred == false
				abort("Canceled: the post wasn't already starred.\n\n".red)
			else
				puts "\nUnstarring post ".green + "#{postID}\n".brown
				@api.unstarPost(postID)
				puts "\nSuccessfully unstarred the post.\n\n".green
			end
		else
			abort("\nsyntax error\n".red)
		end
	end
	def ayadnReposting(action, postID)
		$tools.ayadn_configuration[:progress_indicator] = false
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
			if you_reposted
				abort("Canceled: you already reposted this post.\n\n".red)
			else
				puts "\nReposting post ".green + "#{postID}\n".brown
				@api.repostPost(postID)
				puts "\nSuccessfully reposted the post.\n\n".green
			end
		elsif action == "unrepost"
			if you_reposted
				puts "\nUnreposting post ".green + "#{postID}\n".brown
				@api.unrepostPost(postID)
				puts "\nSuccessfully unreposted the post.\n\n".green
			else
				abort("Canceled: this post wasn't reposted by you.\n\n".red)
			end
		else
			abort($status.errorSyntax)
		end
	end
	def ayadnReset(target, content, option)
		$tools.files_ops("reset", target, content, option)
	end
	def ayadnSkipSource(action, source)
		puts "Current skipped sources: ".green + $tools.config['skipped']['sources'].join(", ").red + "\n\n"
		if action == "add"
			puts "Adding ".green + source.red + " to the skipped sources.".green + "\n\n"
			$tools.config['skipped']['sources'].each do |config_sources|
				if config_sources == source
					puts "#{source}".red + " is already skipped.\n\n".green
					exit
				end
			end
			$tools.config['skipped']['sources'].push(source)
			puts "New skipped sources: ".green + $tools.config['skipped']['sources'].join(", ").red + "\n\n"
			$tools.saveConfig
		elsif action == "remove"
			puts "Removing ".green + source.red + " from the skipped sources.".green + "\n\n"
			$tools.config['skipped']['sources'].each do |config_sources|
				if config_sources == source
					$tools.config['skipped']['sources'].delete(config_sources)
				end
			end
			puts "New skipped sources: ".green + $tools.config['skipped']['sources'].join(", ").red + "\n\n"
			$tools.saveConfig
		end
 	end
 	def ayadnSkipTag(action, tag)
		puts "Current skipped #hashtags: ".green + $tools.config['skipped']['hashtags'].join(", ").red + "\n\n"
		if action == "add"
			puts "Adding ".green + tag.red + " to the skipped #hashtags.".green + "\n\n"
			$tools.config['skipped']['hashtags'].each do |config_tags|
				if config_tags == tag
					puts "#{tag}".red + " is already skipped.\n\n".green
					exit
				end
			end
			$tools.config['skipped']['hashtags'].push(tag.downcase)
			puts "New skipped #hashtags: ".green + $tools.config['skipped']['hashtags'].join(", ").red + "\n\n"
			$tools.saveConfig
		elsif action == "remove"
			puts "Removing ".green + tag.red + " from the skipped #hashtags.".green + "\n\n"
			$tools.config['skipped']['hashtags'].each do |config_tags|
				if config_tags == tag
					$tools.config['skipped']['hashtags'].delete(config_tags)
				end
			end
			puts "New skipped #hashtags: ".green + $tools.config['skipped']['hashtags'].join(", ").red + "\n\n"
			$tools.saveConfig
		end
 	end
 	def ayadnSkipMention(action, mention)
		puts "Current skipped @mentions: ".green + $tools.config['skipped']['mentions'].join(", ").red + "\n\n"
		if action == "add"
			puts "Adding ".green + mention.red + " to the skipped @mentions.".green + "\n\n"
			$tools.config['skipped']['mentions'].each do |config_mentions|
				if config_mentions == mention
					puts "#{mention}".red + " is already skipped.\n\n".green
					exit
				end
			end
			$tools.config['skipped']['mentions'].push(mention.downcase)
			puts "New skipped @mentions: ".green + $tools.config['skipped']['mentions'].join(", ").red + "\n\n"
			$tools.saveConfig
		elsif action == "remove"
			puts "Removing ".green + mention.red + " from the skipped @mentions.".green + "\n\n"
			$tools.config['skipped']['mentions'].each do |config_mentions|
				if config_mentions == mention
					$tools.config['skipped']['mentions'].delete(config_mentions)
				end
			end
			puts "New skipped @mentions: ".green + $tools.config['skipped']['mentions'].join(", ").red + "\n\n"
			$tools.saveConfig
		end
 	end

 	# experimenting without curl
 	# def ayadnFileUpload(file_name)
 	# 	# puts "\nUploading ".green + file_name.brown + "\n"
 	# 	# response = @api.createIncompleteFileUpload(file_name)
 	# 	# puts response.inspect        #SUCCESS
 	# 	# THEN multipart => #FAIL
 	# end


 	def ayadnFiles(action, target, value)
 		case action
 		when "list"
			big_view = ""
 			with_url = false
 			if value == "all"
 				puts "\nGetting the list of all your files...\n".green
 				beforeID = nil
 				pagination_array = []
 				i = 1
		    	loop do
		    		view, file_url, pagination_array = @view.new(@api.getFilesList(beforeID)).showFilesList(with_url, true)
		    		beforeID = pagination_array.last
		    		break if beforeID == nil
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
				view, file_url, pagination_array = @view.new(@api.getFilesList(nil)).showFilesList(with_url, false)
				big_view += view
			end
 			puts big_view
 		when "download"
 			#with_url = true
 			with_url = false
 			$tools.files_ops("makedir", $tools.ayadn_configuration[:files_path])
 			if target.split(",").length == 1
	 			view, file_url, file_name = @view.new(@api.getSingleFile(target)).showFileInfo(with_url)
	 			puts "\nDownloading file ".green + target.to_s.brown
	 			puts view
	 			#new_file_name = "#{target}_#{file_name}" # should put target before .ext instead
	 			new_file_name = "#{file_name}"
	 			download_file_path = $tools.ayadn_configuration[:files_path] + "/#{new_file_name}"
	 			if !File.exists?download_file_path
	 				resp = @api.clientHTTP("download", file_url)
		 			f = File.new(download_file_path, "wb")
		 				f.puts(resp.body)
		 			f.close
		 			puts "File downloaded in ".green + $tools.ayadn_configuration[:files_path].pink + "/#{new_file_name}".brown + "\n\n"
		 		else
		 			puts "Canceled: ".red + "#{new_file_name} ".pink + "already exists in ".red + "#{$tools.ayadn_configuration[:files_path]}".brown + "\n\n"
	 			end
	 		else
	 			@hash = @api.getMultipleFiles(target)
	 			@hash['data'].each do |unique_file|
		 			view, file_url, file_name = @view.new(nil).buildFileInfo(unique_file, with_url)
		 			unique_file_id = unique_file['id']
		 			puts "\nDownloading file ".green + unique_file_id.to_s.brown
		 			puts view
		 			new_file_name = "#{unique_file_id}_#{file_name}"
		 			download_file_path = $tools.ayadn_configuration[:files_path] + "/#{new_file_name}"
		 			if !File.exists?download_file_path
	 					resp = @api.clientHTTP("download", file_url)
			 			f = File.new(download_file_path, "wb")
			 				f.puts(resp.body)
			 			f.close
			 			puts "File downloaded in ".green + $tools.ayadn_configuration[:files_path].pink + "/#{new_file_name}".brown + "\n\n"
			 		else
			 			puts "Canceled: ".red + "#{new_file_name} ".pink + "already exists in ".red + "#{$tools.ayadn_configuration[:files_path]}".brown + "\n\n"
		 			end
		 		end
	 		end
	 	when "upload"
	 		case RbConfig::CONFIG['host_os']     
            when /mswin|mingw|cygwin/
            	puts "\nThis feature doesn't work on Windows yet. Sorry.\n\n".red
            	exit
            end
 			$tools.files_ops("makedir", $tools.ayadn_configuration[:files_path])
 			uploaded_ids = []
 			target.split(",").each do |file|
 				puts "Uploading ".cyan + "#{File.basename(file)}".brown + "\n\n"
 				begin
 					resp = JSON.parse($tools.uploadFiles(file, @token))
 				rescue => e
 					puts "\nERROR: ".red + e.inspect.red + "\n\n"
 					exit
 				end
 				$tools.meta(resp['meta'])
 				uploaded_ids.push(resp['data']['id'])
 			end
			view, file_url, pagination_array = @view.new(@api.getFilesList(nil)).showFilesList(with_url, false)
			uploaded_ids.each do |id|
				view.gsub!("#{id}", "#{id}".reverse_color)
			end
			puts view
		when "remove", "delete-file"
			puts "\nWARNING: ".red + "delete a file ONLY is you're sure it's not referenced by a post or a message.\n\n".pink
			puts "Do you wish to continue? (y/N) ".reddish
			if STDIN.getch == ("y" || "Y")
				puts "\nPlease wait...".green
				resp = JSON.parse(@api.deleteFile(target))
 				$tools.meta(resp['meta'])
			else
				puts "\n\nCanceled.\n\n".red
				exit
			end
		when "public", "private"
			puts "\nChanging file attribute...".green
			if action == "public"
				data = {
					"public" => true
				}.to_json
			else
				data = {
					"public" => false
				}.to_json
			end
			response = @api.httpPutFile(target, data)
			resp = JSON.parse(response.body)
			meta = resp['meta']
			if meta['code'] == 200
				puts "\nDone!\n".green
 				changed_file_id = resp['data']['id']
				view, file_url, pagination_array = @view.new(@api.getFilesList(nil)).showFilesList(with_url, false)
				view.gsub!("#{changed_file_id}", "#{changed_file_id}".reverse_color)
				puts view
			else
				puts "\nERROR: #{meta.inspect}\n".red
			end
 		end
 	end

 	def ayadnBookmark(*args)
 		action = args[0][0]
 		post_id = args[0][1]
 		tags = args[0][2]
 		case action
 		when "pin"
 			hash = @api.getSinglePost(post_id)
 			data = hash['data']
			post_text = data['text']
			user_name = data['user']['username']
			link = data['entities']['links'][0]['url']
 			if $tools.config['pinboard']['username'] != nil
 				puts "Saving post ".green + post_id.brown + " to Pinboard...\n".green
 				$tools.saveToPinboard(post_id, $tools.config['pinboard']['username'], URI.unescape(Base64::decode64($tools.config['pinboard']['password'])), link, tags, post_text, user_name)
 				puts "Done!\n\n".green
 			else
 				puts "\nConfiguration does not include your Pinbard credentials.\n".red
 				begin
 					puts "Please enter your Pinboard username (CTRL+C to cancel): ".green
 					pin_username = STDIN.gets.chomp()
 					puts "\nPlease enter your Pinboard password (invisible, CTRL+C to cancel): ".green
 					pin_password = STDIN.noecho(&:gets).chomp()
 				rescue Exception
 					abort($status.stopped)
 				end
 				$tools.config['pinboard']['username'] = pin_username
 				$tools.config['pinboard']['password'] = URI.escape(Base64::encode64(pin_password))
 				$tools.saveConfig
 				puts "Saving post ".green + post_id.brown + " to Pinboard...\n".green
 				$tools.saveToPinboard(post_id, pin_username, pin_password, link, tags, post_text, user_name)
 				puts "Done!\n\n".green
 			end
 		end
 	end

 	### experiment
 	### not DRY at all, this is ok, chill out
 	# def ayadnRecord(item)
 	# 	# first create with curl -i -H 'Authorization: BEARER xxx' "https://stream-channel.app.net/stream/user?auto_delete=1&include_annotations=1"
 	# 	# it stays open and returns a stream_id in the headers
 	# 	# TODO: replace curl with a good connection system with HTTP or Rest-Client

 	# 	command = "sleep 1; curl -i -H 'Authorization: BEARER #{@token}' 'https://stream-channel.app.net/stream/user?auto_delete=1&include_annotations=1'"
 	# 	pid = Process.spawn(command)
  #       Process.detach(pid)

 	# 	puts "Enter stream id: "
 	# 	stream_id = STDIN.gets.chomp
 	# 	last_page_id = nil
 	# 	start = Time.now
 	# 	case item
 	# 	when "global" # works :)
 	# 		@url = "https://alpha-api.app.net/stream/0/posts/stream/global?connection_id=#{stream_id}&since_id=#{last_page_id}"
 	# 	when "unified" # doesn't work, have to implement some sort of real keep-alive connection
 	# 		@url = "https://alpha-api.app.net/stream/0/posts/stream/unified?connection_id=#{stream_id}&since_id=#{last_page_id}&include_directed_posts=1"
 	# 	end
		# puts "\nRecording stream in #{$tools.ayadn_configuration[:files_path]}/rec-#{item}.json\n\n"
		# uri = URI.parse(@url)
		# https = Net::HTTP.new(uri.host,uri.port)
		# https.use_ssl = true
		# https.verify_mode = OpenSSL::SSL::VERIFY_NONE
		# request = Net::HTTP::Get.new(uri.request_uri)
		# request["Authorization"] = "Bearer #{@token}"
		# request["Content-Type"] = "application/json"
		# response = https.request(request)
		# @hash = JSON.parse(response.body)
		# big_stream = @hash['data']
		# f = File.new($tools.ayadn_configuration[:files_path] + "/rec-#{item}.json", 'w')
		# 	f.puts(big_stream.to_json)
		# f.close
		# stream, last_page_id = completeStream
		# displayScrollStream(stream)
		# number_of_connections = 1
		# file_operations_timer = 0
		# loop do
 	# 		begin
 	# 			case item
		#  		when "global"		
		#  			@url = "https://alpha-api.app.net/stream/0/posts/stream/global?connection_id=#{stream_id}&since_id=#{last_page_id}"
		#  		when "unified"
		#  			@url = "https://alpha-api.app.net/stream/0/posts/stream/unified?connection_id=#{stream_id}&since_id=#{last_page_id}&include_directed_posts=1"
		#  		end
 	# 			uri = URI.parse(@url)
 	# 			request = Net::HTTP::Get.new(uri.request_uri)
 	# 			request["Authorization"] = "Bearer #{@token}"
 	# 			request["Content-Type"] = "application/json"
 	# 			before_request_id = last_page_id
		# 		response = https.request(request)
		# 		@hash = JSON.parse(response.body)
		# 		stream, last_page_id = completeStream
		# 		displayScrollStream(stream)
		# 		if last_page_id == nil
		# 			last_page_id = before_request_id
		# 			sleep 0.5 # trying to play nice with the API limits
		# 			number_of_connections += 1
		# 			next
		# 		end
		# 		# don't let it run for days, it will eat your RAM
		# 		# + the simple file dump isn't ok in the long run
		# 		big_stream << @hash['data']
		# 		number_of_connections += 1
		# 		file_operations_timer += 1
		# 		sleep 0.2 # trying to play nice with the API limits
		# 		if file_operations_timer == 10
		# 			puts "\nRecording stream in #{$tools.ayadn_configuration[:files_path]}/rec-#{item}.json\n\n".green
		# 			#big_json = JSON.parse(IO.read($tools.ayadn_configuration[:files_path] + "/rec-#{item}.json"))
		# 			f = File.new($tools.ayadn_configuration[:files_path] + "/rec-#{item}.json", 'w')
		# 				f.puts(big_stream.to_json)
		# 			f.close
		# 			file_operations_timer = 0
		# 		end
		# 	rescue Exception => e
		# 		puts e.inspect
		# 		puts e.to_s
		# 		finish = Time.now
		# 		elapsed = finish.to_f - start.to_f
		# 		mins, secs = elapsed.divmod 60.0
		# 		puts "\nRequests: #{number_of_connections}\n"
		# 		puts "Elapsed time (min:secs.msecs): "
		# 		puts("%3d:%04.2f"%[mins.to_i, secs])
		# 		puts "\nStream recorded in #{$tools.ayadn_configuration[:files_path]}/rec-#{item}.json"
		# 		exit
		# 	end
		# end
 	# end
end













